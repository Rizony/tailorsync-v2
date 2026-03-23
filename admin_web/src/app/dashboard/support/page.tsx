'use client';

import { useEffect, useState } from 'react';
import { supabase } from '@/lib/supabase';
import { CheckCircle } from 'lucide-react';

export default function SupportTicketsPage() {
    const [tickets, setTickets] = useState<any[]>([]);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        fetchTickets();
    }, []);

    const fetchTickets = async () => {
        try {
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

    const markResolved = async (id: string) => {
        try {
            const { error } = await supabase
                .from('support_tickets')
                .update({
                    status: 'resolved',
                    resolved_at: new Date().toISOString()
                })
                .eq('id', id);

            if (error) throw error;
            fetchTickets();
        } catch (err) {
            alert('Failed to resolve ticket.');
        }
    };

    return (
        <div className="space-y-6">
            <div className="flex items-center justify-between">
                <h1 className="text-2xl font-bold text-gray-900">Support Tickets</h1>
                <button onClick={fetchTickets} className="text-sm text-blue-600 hover:underline">Refresh List</button>
            </div>

            <div className="bg-white shadow-sm border border-gray-200 rounded-lg overflow-hidden">
                <table className="min-w-full divide-y divide-gray-200">
                    <thead className="bg-gray-50">
                        <tr>
                            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Subject</th>
                            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">User</th>
                            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Status</th>
                            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Priority</th>
                            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Last Active</th>
                            <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">Action</th>
                        </tr>
                    </thead>
                    <tbody className="bg-white divide-y divide-gray-200">
                        {loading ? (
                            <tr><td colSpan={6} className="px-6 py-10 text-center text-sm text-gray-500">Loading tickets...</td></tr>
                        ) : tickets.length === 0 ? (
                            <tr><td colSpan={6} className="px-6 py-10 text-center text-sm text-gray-500">No support tickets found.</td></tr>
                        ) : (
                            tickets.map((ticket) => (
                                <tr key={ticket.id} className="hover:bg-gray-50">
                                    <td className="px-6 py-4">
                                        <div className="text-sm font-medium text-gray-900">{ticket.subject}</div>
                                        <div className="text-xs text-gray-500">#{ticket.id.substring(0, 8).toUpperCase()}</div>
                                    </td>
                                    <td className="px-6 py-4">
                                        <div className="text-sm text-gray-900">{ticket.profiles?.full_name}</div>
                                        <div className="text-xs text-gray-500">{ticket.profiles?.shop_name}</div>
                                    </td>
                                    <td className="px-6 py-4">
                                        <span className={`px-2 inline-flex text-xs leading-5 font-semibold rounded-full ${
                                            ticket.status === 'resolved' ? 'bg-green-100 text-green-800' : 
                                            ticket.status === 'open' ? 'bg-blue-100 text-blue-800' : 'bg-orange-100 text-orange-800'
                                        }`}>
                                            {ticket.status.toUpperCase()}
                                        </span>
                                    </td>
                                    <td className="px-6 py-4">
                                        <span className={`text-xs font-medium ${
                                            ticket.priority === 'high' ? 'text-red-600' : 
                                            ticket.priority === 'medium' ? 'text-orange-600' : 'text-blue-600'
                                        }`}>
                                            {ticket.priority.toUpperCase()}
                                        </span>
                                    </td>
                                    <td className="px-6 py-4 text-sm text-gray-500">
                                        {new Date(ticket.updated_at).toLocaleDateString()}
                                    </td>
                                    <td className="px-6 py-4 text-right text-sm font-medium">
                                        <button 
                                            onClick={() => window.location.href = `/dashboard/support/${ticket.id}`}
                                            className="text-blue-600 hover:text-blue-900"
                                        >
                                            View & Reply
                                        </button>
                                    </td>
                                </tr>
                            ))
                        )}
                    </tbody>
                </table>
            </div>
        </div>
    );
}
