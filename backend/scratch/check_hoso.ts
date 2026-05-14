import { PrismaClient } from "@prisma/client";
const prisma = new PrismaClient();
async function main() {
  const hoso = await prisma.hoSoDangKy.findMany({
    select: {
      MaHoSo: true,
      GiayKhamSucKhoe: true,
      Anh3x4: true,
    },
  });
  console.log("Hồ sơ đăng ký:");
  console.log(JSON.stringify(hoso, null, 2));
}
main();
