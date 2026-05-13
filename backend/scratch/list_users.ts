import { PrismaClient } from "@prisma/client";
const prisma = new PrismaClient();
async function main() {
  const users = await prisma.hocVien.findMany();
  console.log(JSON.stringify(users, null, 2));
}
main();
