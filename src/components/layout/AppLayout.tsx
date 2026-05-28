import { NavLink } from 'react-router';
import type { PropsWithChildren } from 'react';

const navItems = [
  { to: '/', label: 'ホーム' },
  { to: '/suggest', label: '提案' },
  { to: '/history', label: '履歴' },
  { to: '/settings', label: '設定' },
];

export function AppLayout({ children }: PropsWithChildren) {
  return (
    <div className="min-h-screen bg-[#f6faf7] text-[#102018]">
      <header className="border-b border-emerald-900/10 bg-white/80 backdrop-blur">
        <div className="mx-auto flex max-w-5xl flex-col gap-4 px-4 py-5 sm:flex-row sm:items-center sm:justify-between">
          <div>
            <p className="text-sm text-emerald-900/70">空いた時間に、ちょっと新しい体験を。</p>
            <h1 className="text-2xl font-bold tracking-tight text-emerald-950">よりみち日和</h1>
          </div>
          <nav className="flex flex-wrap gap-2 text-sm">
            {navItems.map((item) => (
              <NavLink
                key={item.to}
                to={item.to}
                className={({ isActive }) =>
                  `rounded-full px-3 py-2 transition ${
                    isActive
                      ? 'bg-emerald-900 text-white'
                      : 'bg-emerald-50 text-emerald-950 hover:bg-emerald-100'
                  }`
                }
                end={item.to === '/'}
              >
                {item.label}
              </NavLink>
            ))}
          </nav>
        </div>
      </header>
      <main className="mx-auto max-w-5xl px-4 py-8">{children}</main>
    </div>
  );
}
