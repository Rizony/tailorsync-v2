'use client';

import { useEffect, useState } from 'react';
import { supabase } from '@/lib/supabase';
import { ShieldCheck, Search, CheckCircle, XCircle } from 'lucide-react';
import { Card } from '@/components/ui/Card';
import { Input } from '@/components/ui/Input';
import { EmptyState } from '@/components/ui/EmptyState';
import { Spinner } from '@/components/ui/Misc';
import { typography } from '@/theme/typography';
import { cn, formatDate } from '@/lib/utils';
import { colors } from '@/theme/colors';

export default function KYCPage() {
    const [tailors, setTailors] = useState<any[]>([]);
    const [loading, setLoading] = useState(true);
    const [search, setSearch] = useState('');
    const [processingId, setProcessingId] = useState<string | null>(null);

    useEffect(() => {
        fetchKYC();
    }, []);

    const fetchKYC = async () => {
        try {
            setLoading(true);
            const { data, error } = await supabase
                .from('profiles')
                .select('*')
                .not('kyc_document_url', 'is', null) // Only fetch those who uploaded
                .order('created_at', { ascending: false });

            if (error) throw error;
            setTailors(data || []);
        } catch (err) {
            console.error(err);
        } finally {
            setLoading(false);
        }
    };

    const handleAction = async (id: string, isVerified: boolean, newStatus: string) => {
        try {
            setProcessingId(id);
            const { error } = await supabase
                .from('profiles')
                .update({ is_kyc_verified: isVerified, kyc_status: newStatus })
                .eq('id', id);

            if (error) throw error;
            await fetchKYC();
        } catch (err) {
            console.error('Failed to update KYC status:', err);
            alert('Failed to update KYC status');
        } finally {
            setProcessingId(null);
        }
    };

    const filteredTailors = tailors.filter((t) =>
        (t.full_name?.toLowerCase().includes(search.toLowerCase())) ||
        (t.shop_name?.toLowerCase().includes(search.toLowerCase()))
    );

    return (
        <div className="space-y-6 fade-in">
            <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 border-b border-gray-100 pb-5">
                <div>
                    <h1 className={cn(typography.h2, colors.text.primary)}>KYC Verification</h1>
                    <p className={cn(typography.body, colors.text.secondary, "mt-1")}>
                        Review and approve tailor government IDs.
                    </p>
                </div>
                <button 
                  onClick={fetchKYC} 
                  className="text-sm font-medium text-blue-600 hover:text-blue-700 hover:underline transition-colors"
                >
                  Refresh Data
                </button>
            </div>

            <Card className="shadow-lg shadow-gray-100/50 border-gray-100/60 pb-2">
                <div className="p-5 border-b border-gray-100 bg-gray-50/30">
                    <div className="max-w-md">
                        <Input
                            type="text"
                            value={search}
                            onChange={(e) => setSearch(e.target.value)}
                            placeholder="Search by name or shop..."
                            icon={<Search className="h-5 w-5" />}
                        />
                    </div>
                </div>

                <div className="overflow-x-auto min-h-[300px]">
                    <table className="min-w-full divide-y divide-gray-100">
                        <thead className="bg-gray-50/80">
                            <tr>
                                <th className="px-6 py-4 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider">Tailor Details</th>
                                <th className="px-6 py-4 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider">ID Document</th>
                                <th className="px-6 py-4 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider">Status</th>
                                <th className="px-6 py-4 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider">Actions</th>
                            </tr>
                        </thead>
                        <tbody className="bg-white divide-y divide-gray-50">
                            {loading ? (
                                <tr>
                                    <td colSpan={4} className="px-6 py-12 text-center h-[300px]">
                                        <div className="flex flex-col items-center justify-center space-y-3">
                                            <Spinner className="w-8 h-8" />
                                            <span className="text-sm text-gray-500">Loading KYC requests...</span>
                                        </div>
                                    </td>
                                </tr>
                            ) : tailors.length === 0 ? (
                                <tr>
                                    <td colSpan={4} className="p-8">
                                        <EmptyState 
                                            title="No KYC documents"
                                            description="There are currently no uploaded KYC documents."
                                            icon={<ShieldCheck className="h-10 w-10 text-gray-300" />}
                                        />
                                    </td>
                                </tr>
                            ) : filteredTailors.length === 0 ? (
                                <tr>
                                    <td colSpan={4} className="p-8">
                                        <EmptyState 
                                            title="No matches found"
                                            description={`We couldn't find any tailors matching "${search}".`}
                                            icon={<Search className="h-10 w-10 text-gray-300" />}
                                            action={
                                                <button onClick={() => setSearch('')} className="text-blue-600 hover:underline text-sm font-medium">Clear search limits</button>
                                            }
                                        />
                                    </td>
                                </tr>
                            ) : (
                                filteredTailors.map((tailor) => {
                                  const isVerified = tailor.is_kyc_verified || tailor.kyc_status === 'verified';
                                  const isRejected = tailor.kyc_status === 'rejected';
                                  
                                  return (
                                    <tr key={tailor.id} className="hover:bg-gray-50/50 transition-colors group">
                                        <td className="px-6 py-4 whitespace-nowrap">
                                            <div className="flex items-center">
                                                <div className="h-10 w-10 flex-shrink-0 bg-blue-50 text-blue-700 rounded-full flex items-center justify-center font-bold border border-blue-100 group-hover:bg-white transition-colors">
                                                    {tailor.full_name?.charAt(0) || 'T'}
                                                </div>
                                                <div className="ml-4">
                                                    <div className="text-sm font-semibold text-gray-900">{tailor.full_name || 'No Name'}</div>
                                                    <div className="text-sm text-gray-500">{tailor.email}</div>
                                                </div>
                                            </div>
                                        </td>
                                        <td className="px-6 py-4 whitespace-nowrap">
                                            {tailor.kyc_document_url ? (
                                                <a href={tailor.kyc_document_url} target="_blank" rel="noopener noreferrer" className="text-blue-600 hover:underline text-sm font-medium">
                                                    View Document
                                                </a>
                                            ) : (
                                                <span className="text-gray-400 text-sm">No Document</span>
                                            )}
                                        </td>
                                        <td className="px-6 py-4 whitespace-nowrap">
                                            <span className={cn(
                                                "px-2.5 py-1 inline-flex text-xs leading-5 font-semibold rounded-full border",
                                                isVerified 
                                                    ? 'bg-emerald-50 text-emerald-700 border-emerald-200' 
                                                    : isRejected 
                                                    ? 'bg-red-50 text-red-700 border-red-200'
                                                    : 'bg-amber-50 text-amber-700 border-amber-200'
                                            )}>
                                                {isVerified ? 'Verified' : isRejected ? 'Rejected' : tailor.kyc_status || 'Pending'}
                                            </span>
                                        </td>
                                        <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                                            {processingId === tailor.id ? (
                                              <Spinner className="w-5 h-5 mx-auto" />
                                            ) : (
                                              <div className="flex gap-2">
                                                {!isVerified && (
                                                  <button
                                                    onClick={() => handleAction(tailor.id, true, 'verified')}
                                                    className="inline-flex items-center justify-center gap-1.5 px-3 py-1.5 bg-emerald-600 text-white hover:bg-emerald-700 rounded-md text-xs font-semibold shadow-sm transition-colors"
                                                  >
                                                    <CheckCircle className="w-3.5 h-3.5" /> Approve
                                                  </button>
                                                )}
                                                {!isRejected && (
                                                  <button
                                                    onClick={() => handleAction(tailor.id, false, 'rejected')}
                                                    className="inline-flex items-center justify-center gap-1.5 px-3 py-1.5 bg-white border border-red-200 text-red-600 hover:bg-red-50 rounded-md text-xs font-semibold shadow-sm transition-colors"
                                                  >
                                                    <XCircle className="w-3.5 h-3.5" /> Reject
                                                  </button>
                                                )}
                                              </div>
                                            )}
                                        </td>
                                    </tr>
                                  );
                                })
                            )}
                        </tbody>
                    </table>
                </div>
            </Card>
        </div>
    );
}
