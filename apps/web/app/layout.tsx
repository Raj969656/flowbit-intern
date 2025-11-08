import '../styles/globals.css';

export const metadata = {
  title: 'Flowbit Analytics',
  description: 'Analytics Dashboard',
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body className="p-6 bg-gray-50">
        <header className="mb-6">
          <h1 className="text-2xl font-bold">Flowbit Analytics</h1>
        </header>
        <main className="max-w-6xl mx-auto">{children}</main>
      </body>
    </html>
  );
}
