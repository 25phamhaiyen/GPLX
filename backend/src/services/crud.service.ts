import { prisma } from "../config/db";

type Delegate = {
  findMany: (args?: unknown) => Promise<unknown[]>;
  count: (args?: unknown) => Promise<number>;
  findUnique: (args: unknown) => Promise<unknown>;
  create: (args: unknown) => Promise<unknown>;
  update: (args: unknown) => Promise<unknown>;
  delete: (args: unknown) => Promise<unknown>;
};

export interface CrudOptions {
  modelKey: keyof typeof prisma;
  idField: string;
  searchFields?: string[];
  include?: any;
}

export class CrudService {
  constructor(private opts: CrudOptions) {}

  private get model(): Delegate {
    return prisma[this.opts.modelKey] as unknown as Delegate;
  }

  async list(params: {
    page?: number;
    pageSize?: number;
    search?: string;
    filter?: Record<string, any>;
  }) {
    const page = Math.max(1, Number(params.page) || 1);
    const pageSize = Math.min(100, Math.max(1, Number(params.pageSize) || 10));
    const skip = (page - 1) * pageSize;

    let where: Record<string, any> = { ...params.filter };
    if (params.search && this.opts.searchFields?.length) {
      where.OR = this.opts.searchFields.map((f) => ({
        [f]: { contains: params.search },
      }));
    }

    // Exclude admin users from hocvien list
    if (this.opts.modelKey === "hocVien") {
      where.TenDangNhap = { not: { contains: "admin" } };
    }

    const [data, total] = await Promise.all([
      this.model.findMany({
        where,
        skip,
        take: pageSize,
        include: this.opts.include,
      }),
      this.model.count({ where }),
    ]);
    return {
      data,
      total,
      page,
      pageSize,
      totalPages: Math.ceil(total / pageSize),
    };
  }

  getById(id: number | string) {
    return this.model.findUnique({
      where: {
        [this.opts.idField]: typeof id === "string" ? Number(id) || id : id,
      },
      include: this.opts.include,
    });
  }

  create(data: unknown) {
    return this.model.create({ data });
  }

  update(id: number | string, data: unknown) {
    return this.model.update({
      where: {
        [this.opts.idField]: typeof id === "string" ? Number(id) || id : id,
      },
      data,
    });
  }

  remove(id: number | string) {
    return this.model.delete({
      where: {
        [this.opts.idField]: typeof id === "string" ? Number(id) || id : id,
      },
    });
  }
}
