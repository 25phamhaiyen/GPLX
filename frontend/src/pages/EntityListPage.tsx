import { useEffect, useMemo, useState } from "react";
import { useNavigate, useParams } from "react-router-dom";
import { Calendar, Pencil, Plus, Search, Trash2 } from "lucide-react";
import { api, PageResult } from "@/lib/api";
import { getEntity } from "@/lib/entities";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Card } from "@/components/ui/card";
import { Table, THead, TBody, TR, TH, TD } from "@/components/ui/table";
import { EntityForm } from "@/components/EntityForm";
import { formatDate } from "@/lib/utils";
import { toast } from "sonner";
import { useAuth } from "@/hooks/useAuth";

function get(obj: unknown, path: string): unknown {
  return path.split(".").reduce<unknown>((acc, k) => (acc && typeof acc === "object" ? (acc as Record<string, unknown>)[k] : undefined), obj);
}

export default function EntityListPage() {
  const { user } = useAuth();
  const navigate = useNavigate();
  const { key = "" } = useParams();
  const entity = useMemo(() => getEntity(key, user?.role), [key, user?.role]);

  const [page, setPage] = useState(1);
  const [pageSize] = useState(10);
  const [search, setSearch] = useState("");
  const [searchInput, setSearchInput] = useState("");
  const [result, setResult] = useState<PageResult<Record<string, unknown>> | null>(null);
  const [loading, setLoading] = useState(false);
  const [editing, setEditing] = useState<Record<string, unknown> | null>(null);
  const [open, setOpen] = useState(false);

  if (!entity) return <div>Không tìm thấy hoặc bạn không có quyền truy cập.</div>;

  const isReadOnly = entity.readOnlyRoles?.includes(user?.role || "");

  const load = async () => {
    setLoading(true);
    try {
      const { data } = await api.get(`/${entity.key}`, { params: { page, pageSize, search } });
      setResult(data);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    setPage(1);
    setSearch("");
    setSearchInput("");
  }, [entity.key]);

  useEffect(() => { load(); /* eslint-disable-next-line */ }, [entity.key, page, search]);

  const onDelete = async (id: unknown) => {
    if (!confirm("Xóa bản ghi này?")) return;
    try {
      await api.delete(`/${entity.key}/${id}`);
      toast.success("Đã xóa");
      load();
    } catch { /* handled */ }
  };

  const onEdit = async (row: Record<string, unknown>) => {
    try {
      const id = row[entity.idField];
      const response = await api.get(`/${entity.key}/${id}`);
      setEditing(response.data);
      setOpen(true);
    } catch (err) {
      console.error("Không thể tải dữ liệu để sửa:", err);
      toast.error("Không thể tải dữ liệu chi tiết");
    }
  };

  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between gap-2 flex-wrap">
        <h1 className="text-2xl font-semibold">{entity.label}</h1>
        {!isReadOnly && (
          <Button onClick={() => { setEditing(null); setOpen(true); }}>
            <Plus className="h-4 w-4" /> Thêm mới
          </Button>
        )}
      </div>

      <Card className="p-4">
        <form
          onSubmit={(e) => { e.preventDefault(); setPage(1); setSearch(searchInput); }}
          className="flex gap-2 mb-4"
        >
          <div className="relative flex-1 max-w-md">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
            <Input className="pl-9" placeholder="Tìm kiếm..." value={searchInput} onChange={(e) => setSearchInput(e.target.value)} />
          </div>
          <Button type="submit" variant="secondary">Tìm</Button>
        </form>

        <Table>
          <THead>
            <TR>
              {entity.columns.map((c) => <TH key={c.key}>{c.label}</TH>)}
              {!isReadOnly && <TH className="text-right">Hành động</TH>}
            </TR>
          </THead>
          <TBody>
            {loading && <TR><TD colSpan={entity.columns.length + 1} className="text-center text-muted-foreground">Đang tải...</TD></TR>}
            {!loading && result?.data.length === 0 && <TR><TD colSpan={entity.columns.length + 1} className="text-center text-muted-foreground">Không có dữ liệu</TD></TR>}
            {!loading && result?.data.map((row) => (
              <TR key={String(row[entity.idField])}>
                {entity.columns.map((c) => {
                  const v = get(row, c.key);
                  let display: string;
                  if (v == null) display = "—";
                  else if (c.type === "date") display = formatDate(v as string);
                  else if (c.type === "number") display = Number(v).toLocaleString("vi-VN");
                  else display = String(v);
                  return <TD key={c.key}>{display}</TD>;
                })}
                {!isReadOnly && (
                  <TD className="text-right">
                    <div className="flex justify-end gap-1">
                      {entity.key === "khoahoc" && (
                        <Button size="icon" variant="ghost" onClick={() => navigate(`/entities/lichhoc?search=${encodeURIComponent(row.TenKhoaHoc as string)}`)}>
                          <Calendar className="h-4 w-4 text-blue-500" aria-label="Xem lịch học" />
                        </Button>
                      )}
                      <Button size="icon" variant="ghost" onClick={() => onEdit(row)}>
                        <Pencil className="h-4 w-4" />
                      </Button>
                      <Button size="icon" variant="ghost" onClick={() => onDelete(row[entity.idField])}>
                        <Trash2 className="h-4 w-4 text-destructive" />
                      </Button>
                    </div>
                  </TD>
                )}
              </TR>
            ))}
          </TBody>
        </Table>

        {result && result.totalPages > 1 && (
          <div className="flex items-center justify-between mt-4">
            <p className="text-sm text-muted-foreground">
              Trang {result.page}/{result.totalPages} • {result.total} bản ghi
            </p>
            <div className="flex gap-1">
              <Button size="sm" variant="outline" disabled={page <= 1} onClick={() => setPage((p) => p - 1)}>Trước</Button>
              <Button size="sm" variant="outline" disabled={page >= result.totalPages} onClick={() => setPage((p) => p + 1)}>Sau</Button>
            </div>
          </div>
        )}
      </Card>

      <EntityForm entity={entity} open={open} onClose={() => setOpen(false)} initial={editing} onSaved={load} />
    </div>
  );
}
