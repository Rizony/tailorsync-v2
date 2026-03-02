'use client';

import Link from 'next/link';
import { usePathname, useRouter } from 'next/navigation';
import { Users, LayoutDashboard, CreditCard, Ticket, LogOut } from 'lucide-react';
import { supabase } from '@/lib/supabase';

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
        <div className="flex flex-col w-64 bg-gray-900 border-r border-gray-800 h-screen">
            <div className="flex items-center justify-center h-16 bg-gray-950 border-b border-gray-800">
                <span className="text-white font-bold text-lg tracking-wider">
                    NEEDLIX ADMIN
                </span>
            </div>
            <div className="flex-1 overflow-y-auto">
                <nav className="flex flex-col px-4 py-4 space-y-2">
                    {NAVIGATION.map((item) => {
                        const isActive = pathname === item.href;
                        return (
                            <Link
                                key={item.name}
                                href={item.href}
                                className={`flex items-center px-4 py-3 rounded-lg text-sm transition-colors ${isActive
                                        ? 'bg-blue-600 text-white'
                                        : 'text-gray-300 hover:bg-gray-800 hover:text-white'
                                    }`}
                            >
                                <item.icon className="h-5 w-5 mr-3" />
                                {item.name}
                            </Link>
                        );
                    })}
                </nav>
            </div>
            <div className="p-4 border-t border-gray-800">
                <button
                    onClick={handleLogout}
                    className="flex items-center w-full px-4 py-3 text-sm text-gray-400 hover:text-white hover:bg-red-600/10 rounded-lg transition-colors"
                >
                    <LogOut className="h-5 w-5 mr-3 text-red-500" />
                    Logout
                </button>
            </div>
        </div>
    );
}
