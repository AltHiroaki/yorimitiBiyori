import { createBrowserRouter } from 'react-router';
import { App } from '../App';
import { HomePage } from '../pages/HomePage';
import { SuggestPage } from '../pages/SuggestPage';
import { HistoryPage } from '../pages/HistoryPage';
import { SettingsPage } from '../pages/SettingsPage';

export const router = createBrowserRouter([
  {
    path: '/',
    element: <App />,
    children: [
      { index: true, element: <HomePage /> },
      { path: 'suggest', element: <SuggestPage /> },
      { path: 'history', element: <HistoryPage /> },
      { path: 'settings', element: <SettingsPage /> },
    ],
  },
]);
