import { PrismaClient } from "@prisma/client";
const prisma = new PrismaClient();
async function main() {
  // Fix truncated URLs
  const hoso = await prisma.hoSoDangKy.findMany({
    where: {
      GiayKhamSucKhoe: {
        startsWith: "http://localhost:4000/uploads/",
      },
    },
  });

  for (const hs of hoso) {
    if (hs.GiayKhamSucKhoe && hs.GiayKhamSucKhoe.endsWith("-Screen")) {
      // Find the actual file that matches the truncated name
      const truncated = hs.GiayKhamSucKhoe.split("/").pop() || "";
      const baseName = truncated.replace("-Screen", "");

      // List files in uploads directory
      const fs = require("fs");
      const path = require("path");
      const uploadDir = path.join(process.cwd(), "uploads");
      const files = fs.readdirSync(uploadDir);

      const matchingFile = files.find((f) => f.startsWith(baseName));
      if (matchingFile) {
        const fullUrl = `http://localhost:4000/uploads/${matchingFile}`;
        await prisma.hoSoDangKy.update({
          where: { MaHoSo: hs.MaHoSo },
          data: { GiayKhamSucKhoe: fullUrl },
        });
        console.log(`Fixed MaHoSo ${hs.MaHoSo}: ${fullUrl}`);
      }
    }
  }

  console.log("Done fixing URLs");
}
main();
