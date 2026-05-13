import { Router } from "express";
import { ZodSchema } from "zod";
import { CrudService, CrudOptions } from "../services/crud.service";
import { prisma } from "../config/db";
import { asyncHandler } from "../utils/asyncHandler";
import { validate } from "../middlewares/validate";

export function buildCrudRouter(
  opts: CrudOptions,
  createSchema: ZodSchema,
  updateSchema: ZodSchema,
) {
  const router = Router();
  const svc = new CrudService(opts);

  const WEEK_DAYS = [2, 3, 4, 5, 6, 7, 1];
  const toScheduleDay = (date: Date) =>
    date.getDay() === 0 ? 1 : date.getDay() + 1;
  async function findFreeLecturerAndDay(startDate: Date) {
    const lecturers = await prisma.giangVien.findMany({
      where: { TrangThai: "Hoạt động" },
    });
    if (lecturers.length === 0) return null;

    const lecturerIds = lecturers.map((l) => l.MaGiangVien);
    const assignments = await prisma.giangVien_KhoaHoc.findMany({
      where: { MaGiangVien: { in: lecturerIds } },
      include: { KhoaHoc: { include: { LichHoc: true } } },
    });

    const busyDays = new Map<number, Set<number>>();
    for (const assign of assignments) {
      const daySet = busyDays.get(assign.MaGiangVien) ?? new Set<number>();
      assign.KhoaHoc?.LichHoc?.forEach((lh: any) => {
        if (typeof lh.Thu === "number") daySet.add(lh.Thu);
      });
      busyDays.set(assign.MaGiangVien, daySet);
    }

    const startDay = toScheduleDay(startDate);
    const orderedDays = WEEK_DAYS.slice(WEEK_DAYS.indexOf(startDay)).concat(
      WEEK_DAYS.slice(0, WEEK_DAYS.indexOf(startDay)),
    );

    for (const day of orderedDays) {
      const freeLecturer = lecturers.find(
        (gv) => !busyDays.get(gv.MaGiangVien)?.has(day),
      );
      if (freeLecturer) return { lecturer: freeLecturer, day };
    }

    return { lecturer: lecturers[0], day: orderedDays[0] };
  }

  router.get(
    "/",
    asyncHandler(async (req, res) => {
      const filter: Record<string, any> = {};
      if (req.user && req.user.role === "HOCVIEN") {
        // Automatically filter by current user if the model has MaHocVien
        // We check modelKey to decide
        const needsFilter = ["hoSoDangKy", "gPLX"].includes(
          opts.modelKey as string,
        );
        if (needsFilter) {
          filter.MaHocVien = req.user.userId;
        }
      }

      const result = await svc.list({
        page: Number(req.query.page),
        pageSize: Number(req.query.pageSize),
        search: req.query.search as string,
        filter,
      });
      res.json(result);
    }),
  );

  router.get(
    "/:id",
    asyncHandler(async (req, res) => {
      const item = await svc.getById(String(req.params.id));
      if (!item) return res.status(404).json({ message: "Not found" });
      res.json(item);
    }),
  );

  router.post(
    "/",
    validate(createSchema),
    asyncHandler(async (req, res) => {
      // 1. PRE-CREATION AUTOMATIONS

      // Course (KhoaHoc) Logic: Calculate End Date & Session Count
      if (
        opts.modelKey === "khoaHoc" &&
        req.body.MaLoaiBang &&
        req.body.NgayBatDau
      ) {
        const lb = await prisma.loaiBangLai.findUnique({
          where: { MaLoaiBang: Number(req.body.MaLoaiBang) },
        });
        if (lb) {
          const totalHours = lb.SoGioLyThuyet + lb.SoGioThucHanh;
          const totalSessions = Math.ceil(totalHours / 4); // 4 hours per session
          const start = new Date(req.body.NgayBatDau);
          const end = new Date(start);
          end.setDate(start.getDate() + totalSessions * 7); // 1 session per week

          req.body.NgayKetThuc = end;
          req.body.TrangThai = req.body.TrangThai || "Sắp mở";
          (req as any)._totalSessions = totalSessions;
          (req as any)._lb = lb;
        }
      }

      // C. GPLX: Auto-generate Number and Expiry
      if (
        opts.modelKey === "gPLX" &&
        req.body.MaLoaiBang &&
        req.body.MaHocVien
      ) {
        const lb = await prisma.loaiBangLai.findUnique({
          where: { MaLoaiBang: Number(req.body.MaLoaiBang) },
        });
        const count = await prisma.gPLX.count({
          where: { NgayCap: { gte: new Date(new Date().getFullYear(), 0, 1) } },
        });
        const nam = new Date().getFullYear();
        req.body.SoGPLX = `GPLX-${nam}-${lb?.TenLoaiBang || "XX"}-${String(count + 1).padStart(5, "0")}`;
        const expiry = new Date();
        expiry.setFullYear(expiry.getFullYear() + (lb?.ThoiHanGPLX || 10));
        req.body.NgayHetHan = expiry;
      }

      const record = (await svc.create(req.body)) as any;

      // 2. POST-CREATION AUTOMATIONS
      if (record) {
        console.log("Post-create record", {
          modelKey: opts.modelKey,
          id: record[opts.idField],
        });
        // KhoaHoc: Auto-create LichHoc + LichThi
        if (opts.modelKey === "khoaHoc") {
          const lb =
            (req as any)._lb ||
            (await prisma.loaiBangLai.findUnique({
              where: { MaLoaiBang: record.MaLoaiBang },
            }));

          console.log("Auto-schedule start for KhoaHoc", {
            MaKhoaHoc: record.MaKhoaHoc,
            TenKhoaHoc: record.TenKhoaHoc,
            NgayKetThuc: record.NgayKetThuc,
            MaLoaiBang: record.MaLoaiBang,
            lb: lb?.MaLoaiBang,
          });

          try {
            const startDate = new Date(
              req.body.NgayBatDau || record.NgayBatDau || new Date(),
            );
            const assignment = await findFreeLecturerAndDay(startDate);
            const day = assignment?.day ?? 2;
            const dayName =
              ["", "CN", "T2", "T3", "T4", "T5", "T6", "T7"][day] ?? "T2";

            const lectureStart = new Date(Date.UTC(1970, 0, 1, 7, 30));
            const lectureEnd = new Date(Date.UTC(1970, 0, 1, 11, 30));

            await (prisma as any).lichHoc.create({
              data: {
                MaKhoaHoc: record.MaKhoaHoc,
                Thu: day,
                GioBatDau: lectureStart,
                GioKetThuc: lectureEnd,
                GhiChu: `Lịch học ${dayName}`,
              },
            });

            if (assignment?.lecturer) {
              await prisma.giangVien_KhoaHoc.create({
                data: {
                  MaGiangVien: assignment.lecturer.MaGiangVien,
                  MaKhoaHoc: record.MaKhoaHoc,
                  TrangThai: "Đang dạy",
                },
              });
            }

            const examDate = new Date(record.NgayKetThuc);
            examDate.setDate(
              examDate.getDate() + (lb?.ThoiGianThiSauKhoaHoc || 7),
            );
            const dayOfWeek = examDate.getDay();
            const thu = dayOfWeek === 0 ? 1 : dayOfWeek + 1;
            const examStart = new Date(Date.UTC(1970, 0, 1, 7, 30));
            const examEnd = new Date(Date.UTC(1970, 0, 1, 11, 30));

            await (prisma as any).lichThi.create({
              data: {
                MaKhoaHoc: record.MaKhoaHoc,
                NgayThi: examDate,
                Thu: thu,
                GioBatDau: examStart,
                GioKetThuc: examEnd,
                DiaDiem: "Trung tâm sát hạch",
                GhiChu: `Sát hạch - ${record.TenKhoaHoc}`,
              },
            });
          } catch (err) {
            console.error("Failed to auto-create LichHoc/LichThi:", err);
            // Don't fail the course creation if schedule creation fails
          }
        }

        // ThongTinThi: auto-set NgayNhapDiem on creation
        if (opts.modelKey === "thongTinThi" && !record.NgayNhapDiem) {
          await (prisma as any).thongTinThi.update({
            where: { MaThongTinThi: record.MaThongTinThi },
            data: { NgayNhapDiem: new Date() },
          });
        }
      }

      res.status(201).json(record);
    }),
  );

  router.get(
    "/:id",
    asyncHandler(async (req, res) =>
      res.json(await svc.getById(String(req.params.id))),
    ),
  );

  router.put(
    "/:id",
    validate(updateSchema),
    asyncHandler(async (req, res) => {
      // A. HoSoDangKy: Approval Logic
      if (
        opts.modelKey === "hoSoDangKy" &&
        req.body.TrangThaiHoSo === "Đã duyệt"
      ) {
        const old = await prisma.hoSoDangKy.findUnique({
          where: { MaHoSo: Number(req.params.id) },
          include: { KhoaHoc: true, LoaiBangLai: true },
        });
        if (old && old.TrangThaiHoSo !== "Đã duyệt") {
          const examDate = new Date(old.KhoaHoc.NgayKetThuc);
          examDate.setDate(
            examDate.getDate() + old.LoaiBangLai.ThoiGianThiSauKhoaHoc,
          );
          req.body.ThoiGianThiDuKien = examDate;
          req.body.NgayDuyet = new Date();
          await prisma.khoaHoc.update({
            where: { MaKhoaHoc: old.MaKhoaHoc },
            data: { SoLuongDaDangKy: { increment: 1 } },
          });
        }
      }

      // B. ThongTinThi: Auto-set NgayNhapDiem when scores are entered
      if (
        opts.modelKey === "thongTinThi" &&
        (req.body.DiemLyThuyet !== undefined ||
          req.body.DiemThucHanh !== undefined)
      ) {
        req.body.NgayNhapDiem = new Date();
      }

      const result = await svc.update(String(req.params.id), req.body);

      // C. ThongTinThi: Auto-create DuyetCapGPLX if both scores pass
      if (opts.modelKey === "thongTinThi") {
        const updatedThi = await prisma.thongTinThi.findUnique({
          where: { MaThongTinThi: Number(req.params.id) },
          include: {
            HoSoDangKy: {
              include: { LoaiBangLai: true },
            },
          },
        });
        if (
          updatedThi &&
          updatedThi.DiemLyThuyet !== null &&
          updatedThi.DiemThucHanh !== null
        ) {
          const { DiemDatLyThuyet, DiemDatThucHanh } =
            updatedThi.HoSoDangKy.LoaiBangLai;
          if (
            Number(updatedThi.DiemLyThuyet) >= Number(DiemDatLyThuyet) &&
            Number(updatedThi.DiemThucHanh) >= Number(DiemDatThucHanh)
          ) {
            // Check if DuyetCapGPLX already exists
            const existingDuyet = await prisma.duyetCapGPLX.findUnique({
              where: { MaThongTinThi: updatedThi.MaThongTinThi },
            });
            if (!existingDuyet) {
              // Get default HoiDong (first active one)
              const hoiDong = await prisma.hoiDongSatHach.findFirst({
                where: { TrangThai: "Hoạt động" },
              });
              if (!hoiDong) {
                throw new Error("Không tìm thấy hội đồng sát hạch hoạt động");
              }
              await prisma.duyetCapGPLX.create({
                data: {
                  MaThongTinThi: updatedThi.MaThongTinThi,
                  MaHoiDong: hoiDong.MaHoiDong,
                  NgayNop: new Date(),
                  TrangThaiDuyet: "Chờ duyệt",
                },
              });
            }
          }
        }
      }

      res.json(result);
    }),
  );

  router.delete(
    "/:id",
    asyncHandler(async (req, res) => {
      await svc.remove(String(req.params.id));
      res.json({ ok: true });
    }),
  );

  return router;
}
