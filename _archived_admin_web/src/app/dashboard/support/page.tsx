'use client';

import { useEffect, useState } from 'react';
import { supabase } from '@/lib/supabase';
import { Ticket, ArrowRight, Clock } from 'lucide-react';
import { Card } from '@/components/ui/Card';
import { EmptyState } from '@/components/ui/EmptyState';
import { Spinner } from '@/components/ui/Misc';
import { typography } from '@/theme/typography';
import { cn, formatDate } from '@/lib/utils';
import { colors } from '@/theme/colors';
import Link from 'next/link';

export default function SupportTicketsPage() {
    const [tickets, setTickets] = useState<any[]>([]);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        fetchTickets();
    }, []);

    const fetchTickets = async () => {
        try {
            setLoading(true);
            const { data, error } = await supabase
                .from('support_tickets')
                .select(`
                  *,
                  profiles (full_name, shop_name)
                `)
                .order('created_at', { ascending: false });

            if (error) throw error;
            setTickets(data || []);
        } catch (err) {
            console.error(err);
        } finally {
            setLoading(false);
        }
    };

    return (
        <div className="space-y-6 fade-in">
            <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 border-b border-gray-100 pb-5">
                <div>
                    <h1 className={cn(typography.h2, colors.text.primary)}>Support Tickets</h1>
                    <p className={cn(typography.body, colors.text.secondary, "mt-1")}>
                        Manage and respond to user inquiries and issues.
                    </p>
                </div>
                <button 
                  onClick={fetchTickets} 
                  className="text-sm font-medium text-blue-600 hover:text-blue-700 hover:underline transition-colors flex items-center"
                >
                  <Clock className="w-4 h-4 mr-1.5" /> Refresh List
                </button>
            </div>

            <Card className="shadow-lg shadow-gray-100/50 border-gray-100/60 pb-2">
                <div className="overflow-x-auto min-h-[300px]">
                    <table className="min-w-full divide-y divide-gray-100">
                        <thead className="bg-gray-50/80">
                            <tr>
                                <th className="px-6 py-4 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider">Subject & ID</th>
                                <th className="px-6 py-4 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider">User Details</th>
                                <th className="px-6 py-4 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider">Status</th>
                                <th className="px-6 py-4 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider">Priority</th>
                                <th className="px-6 py-4 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider">Last Active</th>
                                <th className="px-6 py-4 text-right text-xs font-semibold text-gray-500 uppercase tracking-wider">Action</th>
                            </tr>
                        </thead>
                        <tbody className="bg-white divide-y divide-gray-50">
                            {loading ? (
                                <tr>
                                    <td colSpan={6} className="px-6 py-12 text-center h-[300px]">
                                        <div className="flex flex-col items-center justify-center space-y-3">
                                            <Spinner className="w-8 h-8" />
                                            <span className="text-sm text-gray-500">Loading tickets...</span>
                                        </div>
                                    </td>
                                </tr>
                            ) : tickets.length === 0 ? (
                                <tr>
                                    <td colSpan={6} className="p-8">
                                        <EmptyState 
                                            title="No support tickets"
                                            description="There are currently no open support tickets. Everything is running smoothly!"
                                            icon={<Ticket className="h-10 w-10 text-gray-300" />}
                                        />
                                    </td>
                                </tr>
                            ) : (
                                tickets.map((ticket) => (
                                    <tr key={ticket.id} className="hover:bg-gray-50/50 transition-colors group">
                                        <td className="px-6 py-4">
                                            <div className="text-sm font-semibold text-gray-900">{ticket.subject}</div>
                                            <div className="text-xs font-mono text-gray-500 mt-0.5 max-w-[150px] truncate" title={ticket.id}>
                                                #{ticket.id.substring(0, 8).toUpperCase()}
                                            </div>
                                        </td>
                                        <td className="px-6 py-4">
                                            <div className="text-sm font-medium text-gray-900">{ticket.profiles?.full_name || 'Unknown'}</div>
                                            <div className="text-xs text-gray-500 mt-0.5">{ticket.profiles?.shop_name || 'No shop'}</div>
                                        </td>
                                        <td className="px-6 py-4 whitespace-nowrap">
                                            <span className={cn(
                                                "px-2.5 py-1 inline-flex text-xs leading-5 font-semibold rounded-full border",
                                                ticket.status === 'resolved' 
                                                    ? 'bg-emerald-50 text-emerald-700 border-emerald-200' 
                                                    : ticket.status === 'open' 
                                                        ? 'bg-blue-50 text-blue-700 border-blue-200' 
                                                        : 'bg-orange-50 text-orange-700 border-orange-200'
                                            )}>
                                                {ticket.status.toUpperCase()}
                                            </span>
                                        </td>
                                        <td className="px-6 py-4 whitespace-nowrap">
                                            <div className="flex items-center">
                                                <span className={cn(
                                                    "h-2 w-2 rounded-full mr-2",
                                                    ticket.priority === 'high' ? 'bg-red-500 animate-pulse' : 
                                                    ticket.priority === 'medium' ? 'bg-orange-500' : 'bg-blue-500'
                                                )}></span>
                                                <span className={cn(
                                                    "text-xs font-semibold",
                                                    ticket.priority === 'high' ? 'text-red-700' : 
                                                    ticket.priority === 'medium' ? 'text-orange-700' : 'text-blue-700'
                                                )}>
                                                    {ticket.priority.toUpperCase()}
                                                </span>
                                            </div>
                                        </td>
                                        <td className="px-6 py-4 text-sm text-gray-500 whitespace-nowrap">
                                            {formatDate(ticket.updated_at)}
                                        </td>
                                        <td className="px-6 py-4 text-right text-sm font-medium whitespace-nowrap">
                                            <Link 
                                                href={`/dashboard/support/${ticket.id}`}
                                                className="inline-flex items-center text-blue-600 hover:text-blue-700 hover:bg-blue-50 px-3 py-1.5 rounded-md transition-colors border border-transparent hover:border-blue-100"
                                            >
                                                View <ArrowRight className="w-4 h-4 ml-1" />
                                            </Link>
                                        </td>
                                    </tr>
                                ))
                            )}
                        </tbody>
                    </table>
                </div>
            </Card>
        </div>
    );
}
