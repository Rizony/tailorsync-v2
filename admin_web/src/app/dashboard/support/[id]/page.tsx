'use client';

import { useEffect, useState, useRef } from 'react';
import { supabase } from '@/lib/supabase';
import { useParams, useRouter } from 'next/navigation';
import { ArrowLeft, Send, CheckCircle, Clock, User, Store } from 'lucide-react';

export default function TicketDetailsPage() {
    const { id: ticketId } = useParams();
    const router = useRouter();
    const [ticket, setTicket] = useState<any>(null);
    const [messages, setMessages] = useState<any[]>([]);
    const [newMessage, setNewMessage] = useState('');
    const [loading, setLoading] = useState(true);
    const [sending, setSending] = useState(false);
    const scrollRef = useRef<HTMLDivElement>(null);

    useEffect(() => {
        if (ticketId) {
            fetchTicket();
            fetchMessages();
            subscribeToMessages();
        }
    }, [ticketId]);

    useEffect(() => {
        if (scrollRef.current) {
            scrollRef.current.scrollTop = scrollRef.current.scrollHeight;
        }
    }, [messages]);

    const fetchTicket = async () => {
        const { data, error } = await supabase
            .from('support_tickets')
            .select('*, profiles(full_name, shop_name, email)')
            .eq('id', ticketId)
            .single();

        if (data) setTicket(data);
        setLoading(false);
    };

    const fetchMessages = async () => {
        const { data } = await supabase
            .from('support_messages')
            .select('*')
            .eq('ticket_id', ticketId)
            .order('created_at', { ascending: true });

        if (data) setMessages(data);
    };

    const subscribeToMessages = () => {
        const channel = supabase
            .channel(`ticket-${ticketId}`)
            .on('postgres_changes', { 
                event: 'INSERT', 
                schema: 'public', 
                table: 'support_messages',
                filter: `ticket_id=eq.${ticketId}`
            }, (payload) => {
                setMessages(prev => [...prev, payload.new]);
            })
            .subscribe();

        return () => {
            supabase.removeChannel(channel);
        };
    };

    const handleSendMessage = async (e: React.FormEvent) => {
        e.preventDefault();
        if (!newMessage.trim() || sending) return;

        setSending(true);
        const { data: { user } } = await supabase.auth.getUser();
        
        if (!user) return;

        const { error } = await supabase.from('support_messages').insert({
            ticket_id: ticketId,
            sender_id: user.id,
            message: newMessage,
            is_admin_reply: true
        });

        if (!error) {
            setNewMessage('');
            // Update ticket updated_at
            await supabase.from('support_tickets').update({ updated_at: new Date().toISOString() }).eq('id', ticketId);
        }
        setSending(false);
    };

    const toggleStatus = async (newStatus: string) => {
        const { error } = await supabase
            .from('support_tickets')
            .update({ status: newStatus })
            .eq('id', ticketId);

        if (!error) {
            setTicket({ ...ticket, status: newStatus });
        }
    };

    if (loading) return <div className="p-8 text-center">Loading ticket details...</div>;
    if (!ticket) return <div className="p-8 text-center text-red-500">Ticket not found.</div>;

    return (
        <div className="flex flex-col h-[calc(100vh-120px)]">
            {/* Header */}
            <div className="bg-white border-b border-gray-200 p-4 flex items-center justify-between">
                <div className="flex items-center gap-4">
                    <button onClick={() => router.back()} className="p-2 hover:bg-gray-100 rounded-full">
                        <ArrowLeft className="w-5 h-5" />
                    </button>
                    <div>
                        <h1 className="text-xl font-bold text-gray-900">{ticket.subject}</h1>
                        <p className="text-xs text-gray-500">Ticket ID: #{ticket.id.substring(0, 8).toUpperCase()}</p>
                    </div>
                </div>
                <div className="flex items-center gap-3">
                    <select 
                        value={ticket.status} 
                        onChange={(e) => toggleStatus(e.target.value)}
                        className="text-sm border-gray-300 rounded-md shadow-sm focus:border-blue-500 focus:ring-blue-500"
                    >
                        <option value="open">Open</option>
                        <option value="in_progress">In Progress</option>
                        <option value="resolved">Resolved</option>
                        <option value="closed">Closed</option>
                    </select>
                </div>
            </div>

            <div className="flex-1 flex overflow-hidden">
                {/* Chat Area */}
                <div className="flex-1 flex flex-col bg-gray-50">
                    <div ref={scrollRef} className="flex-1 overflow-y-auto p-4 space-y-4">
                        {messages.map((msg) => (
                            <div key={msg.id} className={`flex ${msg.is_admin_reply ? 'justify-end' : 'justify-start'}`}>
                                <div className={`max-w-[70%] rounded-lg p-3 ${
                                    msg.is_admin_reply 
                                    ? 'bg-blue-600 text-white rounded-br-none' 
                                    : 'bg-white border border-gray-200 text-gray-900 rounded-bl-none'
                                }`}>
                                    <p className="text-sm">{msg.message}</p>
                                    <p className={`text-[10px] mt-1 ${msg.is_admin_reply ? 'text-blue-100' : 'text-gray-400'}`}>
                                        {new Date(msg.created_at).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
                                    </p>
                                </div>
                            </div>
                        ))}
                    </div>

                    {/* Input Area */}
                    <form onSubmit={handleSendMessage} className="p-4 bg-white border-t border-gray-200 flex gap-2">
                        <input
                            type="text"
                            value={newMessage}
                            onChange={(e) => setNewMessage(e.target.value)}
                            placeholder="Type your response..."
                            className="flex-1 border-gray-300 rounded-lg shadow-sm focus:border-blue-500 focus:ring-blue-500 text-sm"
                        />
                        <button
                            type="submit"
                            disabled={sending || !newMessage.trim()}
                            className="bg-blue-600 text-white p-2 rounded-lg hover:bg-blue-700 disabled:opacity-50"
                        >
                            <Send className="w-5 h-5" />
                        </button>
                    </form>
                </div>

                {/* Sidebar Info */}
                <div className="w-80 bg-white border-l border-gray-200 p-6 space-y-8 hidden md:block">
                    <div>
                        <h3 className="text-xs font-semibold text-gray-500 uppercase tracking-wider mb-4">User Information</h3>
                        <div className="space-y-4">
                            <div className="flex items-center gap-3">
                                <div className="bg-blue-50 p-2 rounded-lg text-blue-600"><User className="w-4 h-4" /></div>
                                <div>
                                    <p className="text-sm font-medium text-gray-900">{ticket.profiles?.full_name}</p>
                                    <p className="text-xs text-gray-500">{ticket.profiles?.email}</p>
                                </div>
                            </div>
                            <div className="flex items-center gap-3">
                                <div className="bg-emerald-50 p-2 rounded-lg text-emerald-600"><Store className="w-4 h-4" /></div>
                                <div>
                                    <p className="text-sm font-medium text-gray-900">{ticket.profiles?.shop_name}</p>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div>
                        <h3 className="text-xs font-semibold text-gray-500 uppercase tracking-wider mb-4">Ticket Stats</h3>
                        <div className="space-y-3">
                            <div className="flex justify-between text-sm">
                                <span className="text-gray-500 italic">Priority</span>
                                <span className={`font-semibold ${
                                    ticket.priority === 'high' ? 'text-red-600' : 
                                    ticket.priority === 'medium' ? 'text-orange-600' : 'text-blue-600'
                                }`}>{ticket.priority.toUpperCase()}</span>
                            </div>
                            <div className="flex justify-between text-sm">
                                <span className="text-gray-500 italic">Created</span>
                                <span className="text-gray-900">{new Date(ticket.created_at).toLocaleDateString()}</span>
                            </div>
                            <div className="flex justify-between text-sm">
                                <span className="text-gray-500 italic">Last Active</span>
                                <span className="text-gray-900">{new Date(ticket.updated_at).toLocaleDateString()}</span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    );
}
