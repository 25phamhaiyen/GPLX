import { defineConfig } from "@prisma/cli";

export default defineConfig({
  datasource: {
    db: {
      provider: "sqlserver",
      url: process.env.DATABASE_URL,
    },
  },
});
