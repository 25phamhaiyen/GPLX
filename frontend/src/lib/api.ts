import axios from "axios";
import { toast } from "sonner";

export const api = axios.create({
  baseURL:
    (import.meta as any).env?.VITE_API_URL || "http://localhost:4000/api",
});

api.interceptors.request.use((config) => {
  const token = localStorage.getItem("token");
  if (token) config.headers.Authorization = `Bearer ${token}`;
  return config;
});

api.interceptors.response.use(
  (r) => r,
  (err) => {
    const msg = err.response?.data?.message || err.message || "Đã xảy ra lỗi";
    if (err.response?.status === 401 && !err.config?.url?.includes("/auth/")) {
      localStorage.removeItem("token");
      window.location.href = "/login";
    } else if (err.response?.status !== 403) {
      toast.error(msg);
    }
    return Promise.reject(err);
  },
);

export interface PageResult<T> {
  data: T[];
  total: number;
  page: number;
  pageSize: number;
  totalPages: number;
}
