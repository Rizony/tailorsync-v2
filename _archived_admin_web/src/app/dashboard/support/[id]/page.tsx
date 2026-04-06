'use client';

import { useEffect, useState, useRef } from 'react';
import { supabase } from '@/lib/supabase';
import { useParams, useRouter } from 'next/navigation';
import { ArrowLeft, Send, CheckCircle, Clock, User, Store } from 'lucide-react';
import { Button } from '@/components/ui/Button';
import { Spinner } from '@/components/ui/Misc';
import { Card } from '@/components/ui/Card';
import { typography } from '@/theme/typography';
import { cn, formatDate } from '@/lib/utils';
import { colors } from '@/theme/colors';

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
            const unsubscribe = subscribeToMessages();
            return () => { unsubscribe(); }
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
        
        if (!user) {
            setSending(false);
            return;
        }

        const { error } = await supabase.from('support_messages').insert({
            ticket_id: ticketId,
            sender_id: user.id,
            message: newMessage,
            is_admin_reply: true
        });

        if (!error) {
            setNewMessage('');
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

    if (loading) return (
        <div className="flex flex-col items-center justify-center min-h-[400px]">
            <Spinner className="w-10 h-10 mb-4" />
            <p className={colors.text.secondary}>Loading ticket details...</p>
        </div>
    );
    
    if (!ticket) return (
        <Card className="p-12 text-center max-w-xl mx-auto mt-12 bg-red-50/50 border-red-100">
            <h2 className="text-xl font-bold text-red-700 mb-2">Ticket Not Found</h2>
            <p className="text-red-500 mb-6">The ticket you are looking for does not exist or has been deleted.</p>
            <Button variant="outline" onClick={() => router.back()}>Go Back</Button>
        </Card>
    );

    return (
        <div className="flex flex-col h-[calc(100vh-100px)] fade-in shadow-xl shadow-gray-200/40 rounded-xl overflow-hidden border border-gray-100 bg-white">
            {/* Header */}
            <div className="bg-gray-50/80 border-b border-gray-100 p-4 px-6 flex flex-col sm:flex-row sm:items-center justify-between gap-4">
                <div className="flex items-center gap-4">
                    <button 
                        onClick={() => router.back()} 
                        className="p-2 hover:bg-white rounded-full transition-colors border border-transparent hover:border-gray-200 shadow-sm"
                    >
                        <ArrowLeft className="w-5 h-5 text-gray-600" />
                    </button>
                    <div>
                        <h1 className="text-xl font-bold text-gray-900">{ticket.subject}</h1>
                        <p className="text-xs font-mono text-gray-500 mt-0.5">Ticket ID: #{ticket.id.substring(0, 8).toUpperCase()}</p>
                    </div>
                </div>
                <div className="flex items-center gap-3">
                    <label className="text-xs font-medium text-gray-500 uppercase tracking-wider">Status:</label>
                    <select 
                        value={ticket.status} 
                        onChange={(e) => toggleStatus(e.target.value)}
                        className={cn(
                            "text-sm font-medium rounded-lg shadow-sm focus:ring-2 border py-2 px-3 outline-none transition-colors cursor-pointer appearance-none bg-white",
                            ticket.status === 'resolved' ? 'border-emerald-200 text-emerald-700 focus:border-emerald-500 focus:ring-emerald-200' :
                            ticket.status === 'open' ? 'border-blue-200 text-blue-700 focus:border-blue-500 focus:ring-blue-200' :
                            'border-orange-200 text-orange-700 focus:border-orange-500 focus:ring-orange-200'
                        )}
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
                <div className="flex-1 flex flex-col bg-[radial-gradient(ellipse_at_top_right,_var(--tw-gradient-stops))] from-blue-50/40 via-white to-gray-50/50">
                    <div ref={scrollRef} className="flex-1 overflow-y-auto p-6 space-y-6">
                        {messages.length === 0 ? (
                            <div className="text-center text-gray-400 italic py-10">No messages yet.</div>
                        ) : (
                            messages.map((msg) => (
                                <div key={msg.id} className={`flex ${msg.is_admin_reply ? 'justify-end' : 'justify-start'} animate-in slide-in-from-bottom-2`}>
                                    <div className={`max-w-[75%] rounded-2xl p-4 shadow-sm ${
                                        msg.is_admin_reply 
                                        ? 'bg-blue-600 text-white rounded-br-sm' 
                                        : 'bg-white border border-gray-100 text-gray-900 rounded-bl-sm shadow-gray-100/50'
                                    }`}>
                                        <p className="text-sm leading-relaxed whitespace-pre-wrap">{msg.message}</p>
                                        <div className={`flex items-center gap-1.5 mt-2 ${msg.is_admin_reply ? 'text-blue-100' : 'text-gray-400'}`}>
                                            <Clock className="w-3 h-3" />
                                            <p className="text-[10px] uppercase font-medium tracking-wider">
                                                {new Date(msg.created_at).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
                                            </p>
                                        </div>
                                    </div>
                                </div>
                            ))
                        )}
                    </div>

                    {/* Input Area */}
                    <div className="p-4 bg-white border-t border-gray-100">
                        <form onSubmit={handleSendMessage} className="flex gap-3 max-w-4xl mx-auto">
                            <input
                                type="text"
                                value={newMessage}
                                onChange={(e) => setNewMessage(e.target.value)}
                                placeholder="Type your response to the user..."
                                className="flex-1 border border-gray-200 rounded-xl px-4 py-3 shadow-sm focus:border-blue-500 focus:ring-2 focus:ring-blue-100 outline-none transition-all text-sm bg-gray-50/50 focus:bg-white"
                                disabled={sending || ticket.status === 'closed'}
                            />
                            <Button
                                type="submit"
                                disabled={sending || !newMessage.trim() || ticket.status === 'closed'}
                                className="px-5 rounded-xl flex items-center gap-2"
                            >
                                <Send className="w-4 h-4" />
                                <span className="hidden sm:inline">Send Response</span>
                            </Button>
                        </form>
                    </div>
                </div>

                {/* Sidebar Info */}
                <div className="w-80 bg-gray-50/50 border-l border-gray-100 p-6 space-y-8 hidden lg:block overflow-y-auto">
                    <div>
                        <h3 className="text-xs font-bold text-gray-500 uppercase tracking-widest mb-4">User Information</h3>
                        <div className="space-y-4 bg-white border border-gray-100 rounded-xl p-4 shadow-sm">
                            <div className="flex items-center gap-3">
                                <div className="bg-blue-50 p-2.5 rounded-lg text-blue-600"><User className="w-4 h-4" /></div>
                                <div className="overflow-hidden">
                                    <p className="text-sm font-bold text-gray-900 truncate">{ticket.profiles?.full_name}</p>
                                    <p className="text-xs text-gray-500 truncate" title={ticket.profiles?.email}>{ticket.profiles?.email}</p>
                                </div>
                            </div>
                            <div className="h-px bg-gray-100 w-full my-2"></div>
                            <div className="flex items-center gap-3">
                                <div className="bg-emerald-50 p-2.5 rounded-lg text-emerald-600"><Store className="w-4 h-4" /></div>
                                <div className="overflow-hidden">
                                    <p className="text-sm font-medium text-gray-700 truncate">{ticket.profiles?.shop_name || 'No shop associated'}</p>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div>
                        <h3 className="text-xs font-bold text-gray-500 uppercase tracking-widest mb-4">Ticket Stats</h3>
                        <div className="space-y-3 bg-white border border-gray-100 rounded-xl p-4 shadow-sm">
                            <div className="flex justify-between items-center text-sm py-1 border-b border-gray-50 last:border-0">
                                <span className="text-gray-500">Priority</span>
                                <span className={cn(
                                    "px-2 py-0.5 rounded-md text-xs font-bold",
                                    ticket.priority === 'high' ? 'bg-red-50 text-red-600' : 
                                    ticket.priority === 'medium' ? 'bg-orange-50 text-orange-600' : 'bg-blue-50 text-blue-600'
                                )}>{ticket.priority.toUpperCase()}</span>
                            </div>
                            <div className="flex justify-between items-center text-sm py-1 border-b border-gray-50 last:border-0">
                                <span className="text-gray-500">Date Opened</span>
                                <span className="text-gray-900 font-medium">{formatDate(ticket.created_at)}</span>
                            </div>
                            <div className="flex justify-between items-center text-sm py-1 border-b border-gray-50 last:border-0">
                                <span className="text-gray-500">Last Updated</span>
                                <span className="text-gray-900 font-medium">{formatDate(ticket.updated_at)}</span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    );
}
