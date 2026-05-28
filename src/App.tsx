import { Outlet } from 'react-router';
import { AppLayout } from './components/layout/AppLayout';

export function App() {
  return (
    <AppLayout>
      <Outlet />
    </AppLayout>
  );
}
