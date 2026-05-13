import { Router } from "express";
import bcrypt from "bcryptjs";
import { z } from "zod";
import { prisma } from "../config/db";
import { signToken } from "../utils/jwt";
import { asyncHandler } from "../utils/asyncHandler";
import { validate } from "../middlewares/validate";

const router = Router();

const loginSchema = z.object({
  username: z.string().min(1),
  password: z.string().min(1),
});

const registerSchema = z.object({
  username: z.string().min(3).max(50),
  password: z.string().min(6),
  fullName: z.string().optional(),
});

router.post(
  "/login",
  validate(loginSchema),
  asyncHandler(async (req, res) => {
    const { username, password } = req.body;
    const user = await prisma.hocVien.findUnique({
      where: { TenDangNhap: username },
    });

    if (!user || !(await bcrypt.compare(password, user.MatKhau))) {
      return res.status(401).json({ message: "Sai tài khoản hoặc mật khẩu" });
    }

    const role = user.TenDangNhap === "admin" ? "ADMIN" : "HOCVIEN";
    const token = signToken({
      userId: user.MaHocVien,
      username: user.TenDangNhap,
      role,
    });

    res.json({
      token,
      user: {
        id: user.MaHocVien,
        username: user.TenDangNhap,
        role,
        fullName: user.HoTen,
      },
    });
  }),
);

import * as D from "../dtos";

router.post(
  "/register",
  validate(D.HocVienCreate),
  asyncHandler(async (req, res) => {
    const data = req.body;
    const existing = await prisma.hocVien.findUnique({
      where: { TenDangNhap: data.TenDangNhap },
    });
    if (existing)
      return res.status(400).json({ message: "Tài khoản đã tồn tại" });

    const hashed = await bcrypt.hash(data.MatKhau, 10);
    const user = await prisma.hocVien.create({
      data: {
        ...data,
        MatKhau: hashed,
        TrangThai: "Hoạt động",
      },
    });
    res.status(201).json({ id: user.MaHocVien, username: user.TenDangNhap });
  }),
);

router.all("*", (_req, res) =>
  res.status(405).json({ message: "Method not allowed" }),
);

export default router;
