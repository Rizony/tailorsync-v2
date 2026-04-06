'use client';

import { useEffect, useState } from 'react';
import { supabase } from '@/lib/supabase';
import { CheckCircle, CreditCard } from 'lucide-react';
import { Card } from '@/components/ui/Card';
import { Spinner } from '@/components/ui/Misc';
import { EmptyState } from '@/components/ui/EmptyState';
import { typography } from '@/theme/typography';
import { cn, formatDate } from '@/lib/utils';
import { colors } from '@/theme/colors';

export default function WithdrawalsPage() {
    const [requests, setRequests] = useState<any[]>([]);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        fetchWithdrawals();
    }, []);

    const fetchWithdrawals = async () => {
        try {
            setLoading(true);
            const { data, error } = await supabase
                .from('withdrawal_requests')
                .select(`
                  *,
                  profiles (full_name, wallet_balance)
                `)
                .order('created_at', { ascending: false });

            if (error) throw error;
            setRequests(data || []);
        } catch (err) {
            console.error(err);
        } finally {
            setLoading(false);
        }
    };

    const markProcessed = async (id: string) => {
        try {
            const { error } = await supabase
                .from('withdrawal_requests')
                .update({
                    status: 'processed',
                    processed_at: new Date().toISOString()
                })
                .eq('id', id);

            if (error) throw error;
            fetchWithdrawals();
        } catch (err) {
            alert('Failed to process withdrawal.');
        }
    };

    return (
        <div className="space-y-6 fade-in">
            <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 border-b border-gray-100 pb-5">
                <div>
                    <h1 className={cn(typography.h2, colors.text.primary)}>Withdrawal Requests</h1>
                    <p className={cn(typography.body, colors.text.secondary, "mt-1")}>
                        Process pending payouts to tailors.
                    </p>
                </div>
                <button 
                  onClick={fetchWithdrawals} 
                  className="text-sm font-medium text-blue-600 hover:text-blue-700 hover:underline transition-colors"
                >
                  Refresh Status
                </button>
            </div>

            <Card className="shadow-lg shadow-gray-100/50 border-gray-100/60 pb-2">
                <div className="overflow-x-auto min-h-[300px]">
                    <table className="min-w-full divide-y divide-gray-100">
                        <thead className="bg-gray-50/80">
                            <tr>
                                <th className="px-6 py-4 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider">User</th>
                                <th className="px-6 py-4 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider">Amount</th>
                                <th className="px-6 py-4 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider">Bank Details</th>
                                <th className="px-6 py-4 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider">Status</th>
                                <th className="px-6 py-4 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider">Requested</th>
                                <th className="px-6 py-4 text-right text-xs font-semibold text-gray-500 uppercase tracking-wider">Actions</th>
                            </tr>
                        </thead>
                        <tbody className="bg-white divide-y divide-gray-50">
                            {loading ? (
                                <tr>
                                    <td colSpan={6} className="px-6 py-12 text-center h-[300px]">
                                        <div className="flex flex-col items-center justify-center space-y-3">
                                            <Spinner className="w-8 h-8" />
                                            <span className="text-sm text-gray-500">Loading requests...</span>
                                        </div>
                                    </td>
                                </tr>
                            ) : requests.length === 0 ? (
                                <tr>
                                    <td colSpan={6} className="p-8">
                                        <EmptyState 
                                            title="No pending withdrawals"
                                            description="There are currently no withdrawal requests to process."
                                            icon={<CreditCard className="h-10 w-10 text-gray-300" />}
                                        />
                                    </td>
                                </tr>
                            ) : (
                                requests.map((req) => (
                                    <tr key={req.id} className="hover:bg-gray-50/50 transition-colors group">
                                        <td className="px-6 py-4 whitespace-nowrap">
                                            <div className="text-sm font-semibold text-gray-900">{req.profiles?.full_name || 'Unknown User'}</div>
                                            <div className="text-xs text-gray-500 mt-0.5">Wallet: ₦{(req.profiles?.wallet_balance || 0).toLocaleString()}</div>
                                        </td>
                                        <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900 font-bold">
                                            ₦{(req.amount || 0).toLocaleString()}
                                        </td>
                                        <td className="px-6 py-4 text-sm text-gray-600 max-w-xs break-words leading-relaxed">
                                            {req.bank_details}
                                        </td>
                                        <td className="px-6 py-4 whitespace-nowrap">
                                            <span className={cn(
                                                "px-2.5 py-1 inline-flex text-xs leading-5 font-semibold rounded-full border",
                                                req.status === 'processed' 
                                                    ? 'bg-emerald-50 text-emerald-700 border-emerald-200' 
                                                    : 'bg-orange-50 text-orange-700 border-orange-200'
                                            )}>
                                                {req.status}
                                            </span>
                                        </td>
                                        <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                                            {formatDate(req.created_at)}
                                        </td>
                                        <td className="px-6 py-4 whitespace-nowrap text-right text-sm">
                                            {req.status === 'pending' ? (
                                                <button
                                                    onClick={() => markProcessed(req.id)}
                                                    className="inline-flex items-center text-emerald-600 hover:text-emerald-700 hover:bg-emerald-50 px-3 py-1.5 rounded-md transition-colors font-medium border border-transparent hover:border-emerald-200"
                                                >
                                                    <CheckCircle className="w-4 h-4 mr-1.5" /> Mark Processed
                                                </button>
                                            ) : (
                                                <span className="text-gray-400 italic text-xs">Completed</span>
                                            )}
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
