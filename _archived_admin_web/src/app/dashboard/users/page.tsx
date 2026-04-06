'use client';

import { useEffect, useState } from 'react';
import { supabase } from '@/lib/supabase';
import { Search, Users as UsersIcon } from 'lucide-react';
import { Card } from '@/components/ui/Card';
import { Input } from '@/components/ui/Input';
import { EmptyState } from '@/components/ui/EmptyState';
import { Spinner } from '@/components/ui/Misc';
import { typography } from '@/theme/typography';
import { cn, formatDate } from '@/lib/utils';
import { colors } from '@/theme/colors';

export default function UsersPage() {
    const [users, setUsers] = useState<any[]>([]);
    const [loading, setLoading] = useState(true);
    const [search, setSearch] = useState('');

    useEffect(() => {
        fetchUsers();
    }, []);

    const fetchUsers = async () => {
        try {
            setLoading(true);
            const { data, error } = await supabase
                .from('profiles')
                .select('*')
                .order('created_at', { ascending: false });

            if (error) throw error;
            setUsers(data || []);
        } catch (err) {
            console.error(err);
        } finally {
            setLoading(false);
        }
    };

    const filteredUsers = users.filter((u) =>
        (u.full_name?.toLowerCase().includes(search.toLowerCase())) ||
        (u.shop_name?.toLowerCase().includes(search.toLowerCase()))
    );

    return (
        <div className="space-y-6 fade-in">
            <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 border-b border-gray-100 pb-5">
                <div>
                    <h1 className={cn(typography.h2, colors.text.primary)}>Tailors Directory</h1>
                    <p className={cn(typography.body, colors.text.secondary, "mt-1")}>
                        Manage all registered tailors on the platform.
                    </p>
                </div>
                <button 
                  onClick={fetchUsers} 
                  className="text-sm font-medium text-blue-600 hover:text-blue-700 hover:underline transition-colors"
                >
                  Refresh Directory
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
                                <th className="px-6 py-4 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider">Plan</th>
                                <th className="px-6 py-4 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider">Wallet Balance</th>
                                <th className="px-6 py-4 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider">Joined Date</th>
                            </tr>
                        </thead>
                        <tbody className="bg-white divide-y divide-gray-50">
                            {loading ? (
                                <tr>
                                    <td colSpan={4} className="px-6 py-12 text-center h-[300px]">
                                        <div className="flex flex-col items-center justify-center space-y-3">
                                            <Spinner className="w-8 h-8" />
                                            <span className="text-sm text-gray-500">Loading directory...</span>
                                        </div>
                                    </td>
                                </tr>
                            ) : users.length === 0 ? (
                                <tr>
                                    <td colSpan={4} className="p-8">
                                        <EmptyState 
                                            title="No tailors found"
                                            description="There are currently no users registered on the platform."
                                            icon={<UsersIcon className="h-10 w-10 text-gray-300" />}
                                        />
                                    </td>
                                </tr>
                            ) : filteredUsers.length === 0 ? (
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
                                filteredUsers.map((user) => (
                                    <tr key={user.id} className="hover:bg-gray-50/50 transition-colors group">
                                        <td className="px-6 py-4 whitespace-nowrap">
                                            <div className="flex items-center">
                                                <div className="h-10 w-10 flex-shrink-0 bg-blue-50 text-blue-700 rounded-full flex items-center justify-center font-bold border border-blue-100 group-hover:bg-white transition-colors">
                                                    {user.full_name?.charAt(0) || 'U'}
                                                </div>
                                                <div className="ml-4">
                                                    <div className="text-sm font-semibold text-gray-900">{user.full_name || 'No Name'}</div>
                                                    <div className="text-sm text-gray-500">{user.shop_name || 'No Shop Name'}</div>
                                                </div>
                                            </div>
                                        </td>
                                        <td className="px-6 py-4 whitespace-nowrap">
                                            <span className={cn(
                                                "px-2.5 py-1 inline-flex text-xs leading-5 font-semibold rounded-full border",
                                                user.subscription_tier === 'premium' 
                                                    ? 'bg-emerald-50 text-emerald-700 border-emerald-200' 
                                                    : 'bg-gray-50 text-gray-700 border-gray-200'
                                            )}>
                                                {user.subscription_tier || 'freemium'}
                                            </span>
                                        </td>
                                        <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900 font-medium">
                                            ₦{(user.wallet_balance || 0).toLocaleString()}
                                        </td>
                                        <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                                            {formatDate(user.created_at)}
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
