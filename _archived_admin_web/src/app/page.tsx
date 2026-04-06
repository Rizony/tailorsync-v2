'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { supabase } from '@/lib/supabase';
import { Lock, Mail } from 'lucide-react';
import { Button } from '@/components/ui/Button';
import { Input } from '@/components/ui/Input';
import { Card, CardBody } from '@/components/ui/Card';
import { ErrorAlert } from '@/components/ui/ErrorAlert';
import { typography } from '@/theme/typography';
import { cn } from '@/lib/utils';
import { colors } from '@/theme/colors';

export default function LoginPage() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);
  const router = useRouter();

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError('');

    try {
      const { data, error: signInError } = await supabase.auth.signInWithPassword({
        email,
        password,
      });

      if (signInError) throw signInError;

      // Verify the user is an admin
      const { data: profile, error: profileError } = await supabase
        .from('profiles')
        .select('is_admin')
        .eq('id', data.user.id)
        .single();

      if (profileError || !profile?.is_admin) {
        await supabase.auth.signOut();
        throw new Error('Access denied. You are not an administrator.');
      }

      router.push('/dashboard');
    } catch (err: any) {
      setError(err.message || 'We could not sign you in with those details. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className={cn("min-h-screen flex text-center flex-col justify-center py-12 px-4 sm:px-6 lg:px-8", colors.background.DEFAULT)}>
      {/* Subtle background gradient to make it feel premium */}
      <div className="absolute inset-0 bg-gradient-to-br from-indigo-50 via-white to-blue-50 opacity-70 border-0 -z-10" />

      <div className="max-w-md w-full mx-auto space-y-8">
        <div>
          <h2 className={cn(typography.h2, "text-gray-900 mt-6")}>
            NEEDLIX Admin
          </h2>
          <p className={cn("mt-2", typography.body, colors.text.secondary)}>
            Sign in to manage the platform
          </p>
        </div>

        <Card className="shadow-xl shadow-blue-900/5 ring-1 ring-gray-900/5 text-left border-gray-100/60">
          <CardBody>
            <form className="space-y-6" onSubmit={handleLogin}>
              {error && (
                <ErrorAlert 
                  title="Sign In Failed" 
                  message={error} 
                />
              )}
              
              <div className="space-y-4">
                <Input
                  label="Email Address"
                  type="email"
                  required
                  value={email}
                  onChange={(e: React.ChangeEvent<HTMLInputElement>) => setEmail(e.target.value)}
                  placeholder="admin@needlix.com"
                  icon={<Mail className="h-5 w-5" />}
                  disabled={loading}
                />

                <Input
                  label="Password"
                  type="password"
                  required
                  value={password}
                  onChange={(e: React.ChangeEvent<HTMLInputElement>) => setPassword(e.target.value)}
                  placeholder="••••••••"
                  icon={<Lock className="h-5 w-5" />}
                  disabled={loading}
                />
              </div>

              <Button
                type="submit"
                fullWidth
                size="lg"
                isLoading={loading}
                className="mt-6"
              >
                Sign In
              </Button>
            </form>
          </CardBody>
        </Card>
      </div>
    </div>
  );
}
