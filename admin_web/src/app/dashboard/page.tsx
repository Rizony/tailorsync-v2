'use client';

import { useEffect, useState } from 'react';
import { supabase } from '@/lib/supabase';
import { Users, CreditCard, Ticket, ShieldCheck, TrendingUp } from 'lucide-react';
import { Card, CardBody } from '@/components/ui/Card';
import { Spinner } from '@/components/ui/Misc';
import { typography } from '@/theme/typography';
import { cn } from '@/lib/utils';
import { colors } from '@/theme/colors';

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

    const statCards = [
        { title: 'Total Tailors', value: stats.totalUsers, icon: Users, color: 'text-blue-600', bg: 'bg-blue-50 border-blue-100', trend: '+12%' },
        { title: 'Premium Subscribers', value: stats.premiumUsers, icon: ShieldCheck, color: 'text-emerald-600', bg: 'bg-emerald-50 border-emerald-100', trend: '+5%' },
        { title: 'Pending Withdrawals', value: stats.pendingWithdrawals, icon: CreditCard, color: 'text-orange-600', bg: 'bg-orange-50 border-orange-100', trend: '-2%' },
        { title: 'Open Tickets', value: stats.openTickets, icon: Ticket, color: 'text-red-600', bg: 'bg-red-50 border-red-100', trend: '+1%' },
    ];

    return (
        <div className="space-y-8 fade-in">
            <div className="flex flex-col md:flex-row md:items-center justify-between border-b border-gray-100 pb-5">
                <div>
                    <h1 className={cn(typography.h2, colors.text.primary)}>System Overview</h1>
                    <p className={cn(typography.body, colors.text.secondary, "mt-1")}>
                        A high-level view of your platform operations.
                    </p>
                </div>
                <div className="mt-4 md:mt-0 text-sm font-medium text-gray-500 bg-white px-4 py-2 rounded-full border border-gray-100 shadow-sm flex items-center">
                    <span className="h-2.5 w-2.5 rounded-full bg-green-500 mr-2 animate-pulse"></span>
                    System Operational
                </div>
            </div>

            {isLoading ? (
                <div className="flex justify-center items-center py-20 min-h-[300px]">
                    <Spinner className="w-10 h-10" />
                </div>
            ) : (
                <div className="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-4">
                    {statCards.map((stat, i) => (
                        <Card key={i} className="hover:shadow-md transition-shadow group border-gray-100/60 shadow-lg shadow-gray-100/50">
                            <CardBody className="p-6">
                                <div className="flex items-center justify-between">
                                    <div className={cn("flex-shrink-0 p-3.5 rounded-xl border transition-colors group-hover:bg-white", stat.bg)}>
                                        <stat.icon className={cn("w-6 h-6", stat.color)} />
                                    </div>
                                    <div className="flex items-center text-sm font-medium text-green-600 bg-green-50 px-2.5 py-1 rounded-full">
                                        <TrendingUp className="w-3.5 h-3.5 mr-1" />
                                        {stat.trend}
                                    </div>
                                </div>
                                <div className="mt-5">
                                    <dt className="text-sm font-medium text-gray-500 truncate">{stat.title}</dt>
                                    <dd className="mt-1 text-3xl font-bold bg-clip-text text-transparent bg-gradient-to-r from-gray-900 to-gray-600">
                                        {stat.value}
                                    </dd>
                                </div>
                            </CardBody>
                        </Card>
                    ))}
                </div>
            )}
        </div>
    );
}
