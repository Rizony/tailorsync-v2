'use client';

import Link from 'next/link';
import { usePathname, useRouter } from 'next/navigation';
import { Users, LayoutDashboard, CreditCard, Ticket, LogOut } from 'lucide-react';
import { supabase } from '@/lib/supabase';
import { cn } from '@/lib/utils';
import { colors } from '@/theme/colors';

const NAVIGATION = [
    { name: 'Overview', href: '/dashboard', icon: LayoutDashboard },
    { name: 'Users', href: '/dashboard/users', icon: Users },
    { name: 'Withdrawals', href: '/dashboard/withdrawals', icon: CreditCard },
    { name: 'Support Tickets', href: '/dashboard/support', icon: Ticket },
];

export default function Sidebar() {
    const pathname = usePathname();
    const router = useRouter();

    const handleLogout = async () => {
        await supabase.auth.signOut();
        router.push('/');
    };

    return (
        <div className={cn("flex flex-col w-64 border-r h-screen shadow-lg z-10 font-sans transition-all", colors.background.darker, colors.border.dark)}>
            <div className={cn("flex items-center justify-center h-16 border-b", colors.border.dark, colors.gradients.premium)}>
                <span className="text-white font-bold text-lg tracking-wider block">
                    NEEDLIX <span className={colors.primary.DEFAULT}>ADMIN</span>
                </span>
            </div>
            <div className="flex-1 overflow-y-auto mt-2">
                <nav className="flex flex-col px-3 py-4 space-y-1.5">
                    {NAVIGATION.map((item) => {
                        const isActive = pathname === item.href || (item.href !== '/dashboard' && pathname.startsWith(item.href));
                        return (
                            <Link
                                key={item.name}
                                href={item.href}
                                className={cn(
                                    'group flex items-center px-4 py-3 rounded-lg text-sm font-medium transition-all duration-200',
                                    isActive
                                        ? cn('text-white shadow-md', colors.gradients.primary)
                                        : 'text-gray-400 hover:bg-gray-800/80 hover:text-white'
                                )}
                            >
                                <item.icon 
                                    className={cn(
                                        "h-5 w-5 mr-3 transition-transform duration-200 group-hover:scale-110",
                                        isActive ? "text-white" : "text-gray-400 group-hover:text-blue-400"
                                    )} 
                                />
                                {item.name}
                            </Link>
                        );
                    })}
                </nav>
            </div>
            <div className={cn("p-4 border-t", colors.border.dark)}>
                <button
                    onClick={handleLogout}
                    className="flex items-center w-full px-4 py-3 text-sm font-medium text-gray-400 hover:text-white hover:bg-red-500/10 rounded-lg transition-colors group"
                >
                    <LogOut className="h-5 w-5 mr-3 text-red-400 transition-transform duration-200 group-hover:-translate-x-1" />
                    Logout
                </button>
            </div>
        </div>
    );
}
