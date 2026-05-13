const { PrismaClient } = require('@prisma/client')
const prisma = new PrismaClient()

async function main() {
  try {
    const res = await prisma.thongTinThi.create({
      data: {
        MaHoSo: 1, // Assuming these exist
        MaHocVien: 1,
        MaKyThi: 1,
        LoaiThi: 'Lần đầu',
        LanThi: 1,
        KetQuaLyThuyet: 'Chưa thi',
        KetQuaThucHanh: 'Chưa thi',
        KetQuaTong: 'Chưa thi'
      }
    })
    console.log("Success:", res)
  } catch (e) {
    console.error("Error:", e)
  } finally {
    await prisma.$disconnect()
  }
}

main()
