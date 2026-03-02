'use client';

import { useEffect, useState } from 'react';
import { supabase } from '@/lib/supabase';
import { Users, CreditCard, Ticket, ShieldCheck } from 'lucide-react';

export default function DashboardOverview() {
    const [stats, setStats] = useState({
        totalUsers: 0,
        premiumUsers: 0,
        pendingWithdrawals: 0,
        openTickets: 0,
    });
    const [isLoading, setIsLoading] = useState(true);

    useEffect(() => {
        const fetchStats = async () => {
            try {
                const [
                    { count: totalUsers },
                    { count: premiumUsers },
                    { count: pendingWithdrawals },
                    { count: openTickets }
                ] = await Promise.all([
                    supabase.from('profiles').select('*', { count: 'exact', head: true }),
                    supabase.from('profiles').select('*', { count: 'exact', head: true }).eq('subscription_tier', 'premium'),
                    supabase.from('withdrawal_requests').select('*', { count: 'exact', head: true }).eq('status', 'pending'),
                    supabase.from('support_tickets').select('*', { count: 'exact', head: true }).eq('status', 'open')
                ]);

                setStats({
                    totalUsers: totalUsers || 0,
                    premiumUsers: premiumUsers || 0,
                    pendingWithdrawals: pendingWithdrawals || 0,
                    openTickets: openTickets || 0,
                });
            } catch (error) {
                console.error('Error fetching stats:', error);
            } finally {
                setIsLoading(false);
            }
        };

        fetchStats();
    }, []);

    if (isLoading) {
        return <div className="flex justify-center mt-20"><div className="w-8 h-8 rounded-full border-4 border-t-blue-600 border-b-blue-600 border-l-transparent border-r-transparent animate-spin"></div></div>;
    }

    const statCards = [
        { title: 'Total Tailors', value: stats.totalUsers, icon: Users, color: 'text-blue-600', bg: 'bg-blue-100' },
        { title: 'Premium Subscribers', value: stats.premiumUsers, icon: ShieldCheck, color: 'text-emerald-600', bg: 'bg-emerald-100' },
        { title: 'Pending Withdrawals', value: stats.pendingWithdrawals, icon: CreditCard, color: 'text-orange-600', bg: 'bg-orange-100' },
        { title: 'Open Tickets', value: stats.openTickets, icon: Ticket, color: 'text-red-600', bg: 'bg-red-100' },
    ];

    return (
        <div className="space-y-6">
            <div>
                <h1 className="text-2xl font-bold text-gray-900">System Overview</h1>
                <p className="text-gray-500 text-sm mt-1">A high-level view of your platform operations.</p>
            </div>

            <div className="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-4">
                {statCards.map((stat, i) => (
                    <div key={i} className="bg-white overflow-hidden rounded-xl shadow-sm border border-gray-100">
                        <div className="p-5 flex items-center">
                            <div className={`flex-shrink-0 p-3 rounded-lg ${stat.bg}`}>
                                <stat.icon className={`w-6 h-6 ${stat.color}`} />
                            </div>
                            <div className="ml-5 w-0 flex-1">
                                <dl>
                                    <dt className="text-sm font-medium text-gray-500 truncate">{stat.title}</dt>
                                    <dd className="space-y-1">
                                        <div className="text-2xl font-bold text-gray-900">{stat.value}</div>
                                    </dd>
                                </dl>
                            </div>
                        </div>
                    </div>
                ))}
            </div>
        </div>
    );
}
