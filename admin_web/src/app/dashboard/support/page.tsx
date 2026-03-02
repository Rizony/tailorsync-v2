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
                <ul className="divide-y divide-gray-200">
                    {loading ? (
                        <li className="p-6 text-center text-sm text-gray-500">Loading tickets...</li>
                    ) : tickets.length === 0 ? (
                        <li className="p-6 text-center text-sm text-gray-500">No support tickets found.</li>
                    ) : (
                        tickets.map((ticket) => (
                            <li key={ticket.id} className="p-6">
                                <div className="flex items-center justify-between">
                                    <div>
                                        <h3 className="text-lg font-medium text-gray-900">{ticket.subject}</h3>
                                        <p className="mt-1 text-sm text-gray-500">From: <span className="font-semibold text-gray-700">{ticket.profiles?.full_name}</span> ({ticket.profiles?.shop_name})</p>
                                    </div>
                                    <div>
                                        <span className={`px-3 py-1 inline-flex text-xs leading-5 font-semibold rounded-full ${ticket.status === 'resolved' ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'}`}>
                                            {ticket.status.toUpperCase()}
                                        </span>
                                    </div>
                                </div>
                                <div className="mt-4 bg-gray-50 p-4 rounded-md border border-gray-100">
                                    <p className="text-sm text-gray-800 whitespace-pre-wrap">{ticket.description}</p>
                                </div>
                                <div className="mt-4 flex items-center justify-between">
                                    <p className="text-xs text-gray-400">Created: {new Date(ticket.created_at).toLocaleString()}</p>

                                    {ticket.status === 'open' && (
                                        <button
                                            onClick={() => markResolved(ticket.id)}
                                            className="inline-flex items-center px-3 py-1 border border-transparent text-xs font-medium rounded shadow-sm text-white bg-emerald-600 hover:bg-emerald-700 focus:outline-none"
                                        >
                                            <CheckCircle className="w-4 h-4 mr-1" /> Mark Resolved
                                        </button>
                                    )}
                                </div>
                            </li>
                        ))
                    )}
                </ul>
            </div>
        </div>
    );
}
