import Sidebar from '@/components/Sidebar';
import { cn } from '@/lib/utils';
import { colors } from '@/theme/colors';

export default function DashboardLayout({
    children,
}: {
    children: React.ReactNode;
}) {
    return (
        <div className={cn("flex h-screen overflow-hidden", colors.background.DEFAULT)}>
            <Sidebar />
            <div className="flex-1 overflow-auto bg-[radial-gradient(ellipse_at_top,_var(--tw-gradient-stops))] from-gray-50 via-white to-gray-100">
                <main className="p-8 max-w-7xl mx-auto w-full">
                    {children}
                </main>
            </div>
        </div>
    );
}
