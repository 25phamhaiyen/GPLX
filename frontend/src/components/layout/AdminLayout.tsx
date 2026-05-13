import { NavLink, Outlet, useNavigate } from "react-router-dom";
import { getAuthorizedEntities } from "@/lib/entities";
import { useAuth } from "@/hooks/useAuth";
import { useTheme } from "@/hooks/useTheme";
import { Button } from "@/components/ui/button";
import { GraduationCap, LayoutDashboard, LogOut, Menu, Moon, Sun } from "lucide-react";
import { useState } from "react";
import { cn } from "@/lib/utils";

export default function AdminLayout() {
  const { user, logout } = useAuth();
  const { theme, toggle } = useTheme();
  const nav = useNavigate();
  const [openMobile, setOpenMobile] = useState(false);

  const items = [
    ...(user?.role === "ADMIN" ? [{ to: "/", label: "Dashboard", icon: LayoutDashboard, end: true }] : []),
    ...getAuthorizedEntities(user?.role).map((e) => ({
      to: `/entity/${e.key}`,
      label: e.label,
      icon: e.icon,
      end: false,
    })),
  ];

  const Sidebar = (
    <aside className="w-64 border-r bg-card flex flex-col h-full">
      <div className="h-16 flex items-center gap-2 px-5 border-b">
        <div className="h-9 w-9 rounded-lg bg-primary/10 grid place-items-center">
          <GraduationCap className="h-5 w-5 text-primary" />
        </div>
        <div>
          <p className="font-semibold leading-none">GPLX Admin</p>
          <p className="text-xs text-muted-foreground mt-0.5">Quản lý đào tạo</p>
        </div>
      </div>
      <nav className="flex-1 overflow-y-auto p-3 space-y-1">
        {items.map((it) => (
          <NavLink
            key={it.to}
            to={it.to}
            end={it.end}
            onClick={() => setOpenMobile(false)}
            className={({ isActive }) =>
              cn(
                "flex items-center gap-3 px-3 py-2 rounded-md text-sm transition-colors",
                isActive ? "bg-primary text-primary-foreground" : "hover:bg-accent text-foreground/80"
              )
            }
          >
            <it.icon className="h-4 w-4" />
            {it.label}
          </NavLink>
        ))}
      </nav>
      <div className="p-3 border-t">
        <div className="text-xs text-muted-foreground mb-2 px-1">
          {user?.fullName || user?.username}
        </div>
        <Button variant="outline" size="sm" className="w-full" onClick={() => { logout(); nav("/login"); }}>
          <LogOut className="h-4 w-4" /> Đăng xuất
        </Button>
      </div>
    </aside>
  );

  return (
    <div className="min-h-screen flex bg-muted/30">
      <div className="hidden md:flex">{Sidebar}</div>
      {openMobile && (
        <div className="md:hidden fixed inset-0 z-40 flex">
          <div className="absolute inset-0 bg-black/50" onClick={() => setOpenMobile(false)} />
          <div className="relative z-50">{Sidebar}</div>
        </div>
      )}

      <main className="flex-1 flex flex-col min-w-0">
        <header className="h-16 border-b bg-card flex items-center justify-between px-4 md:px-6">
          <Button variant="ghost" size="icon" className="md:hidden" onClick={() => setOpenMobile(true)}>
            <Menu className="h-5 w-5" />
          </Button>
          <div className="flex-1" />
          <Button variant="ghost" size="icon" onClick={toggle} aria-label="Toggle theme">
            {theme === "dark" ? <Sun className="h-5 w-5" /> : <Moon className="h-5 w-5" />}
          </Button>
        </header>
        <div className="p-4 md:p-6 flex-1 overflow-auto">
          <Outlet />
        </div>
      </main>
    </div>
  );
}
