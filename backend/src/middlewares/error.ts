import { Request, Response, NextFunction } from "express";
import { ZodError } from "zod";
import { Prisma } from "@prisma/client";

export const errorHandler = (
  err: unknown,
  _req: Request,
  res: Response,
  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  _next: NextFunction
) => {
  console.error("Error:", err);

  if (err instanceof ZodError) {
    const messages = err.errors.map(e => `${e.path.join('.')}: ${e.message}`).join(', ');
    return res.status(400).json({ 
      message: `Lỗi dữ liệu: ${messages}`,
      errors: err.errors 
    });
  }

  if (err instanceof Prisma.PrismaClientKnownRequestError) {
    console.error("Prisma Error Code:", err.code);
    console.error("Prisma Error Meta:", err.meta);
    
    switch (err.code) {
      case 'P2002':
        return res.status(409).json({ message: "Dữ liệu đã tồn tại (trùng mã hoặc giá trị duy nhất)" });
      case 'P2003':
        return res.status(400).json({ 
          message: "Lỗi ràng buộc dữ liệu: Mã liên kết không tồn tại hoặc đang được sử dụng",
          detail: `Trường gây lỗi: ${err.meta?.field_name || 'không xác định'}` 
        });
      case 'P2025':
        return res.status(404).json({ message: "Không tìm thấy bản ghi cần xử lý" });
      default:
        return res.status(400).json({ message: `Lỗi Database (${err.code}): ${err.message}` });
    }
  }

  const e = err as { status?: number; message?: string };
  res.status(e.status || 500).json({ message: e.message || "Lỗi hệ thống không xác định" });
};
