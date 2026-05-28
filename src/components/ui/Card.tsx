import type { PropsWithChildren } from 'react';

type CardProps = PropsWithChildren<{
  className?: string;
}>;

export function Card({ children, className = '' }: CardProps) {
  return <section className={`rounded-2xl border border-emerald-900/10 bg-white p-5 shadow-sm ${className}`}>{children}</section>;
}
