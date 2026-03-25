import React from 'react';
import { cn } from '@/lib/utils';
import { ServerCrash, AlertCircle } from 'lucide-react';
import { Button } from './Button';

interface ErrorAlertProps {
  title?: string;
  message: string;
  onRetry?: () => void;
  className?: string;
  variant?: 'inline' | 'page';
}

export function ErrorAlert({ title = 'An error occurred', message, onRetry, className, variant = 'inline' }: ErrorAlertProps) {
  if (variant === 'page') {
    return (
      <div className={cn('min-h-[400px] flex flex-col items-center justify-center p-8 text-center', className)}>
        <div className="h-16 w-16 bg-red-50 rounded-full flex items-center justify-center mb-4 border border-red-100 shadow-sm">
          <ServerCrash className="h-8 w-8 text-red-500" />
        </div>
        <h3 className="text-lg font-semibold text-gray-900 mb-2">{title}</h3>
        <p className="text-sm text-gray-500 mb-6 max-w-sm">{message}</p>
        {onRetry && (
          <Button variant="outline" onClick={onRetry}>Try Again</Button>
        )}
      </div>
    );
  }

  return (
    <div className={cn('rounded-md bg-red-50 p-4 border border-red-200', className)}>
      <div className="flex">
        <div className="flex-shrink-0">
          <AlertCircle className="h-5 w-5 text-red-400" aria-hidden="true" />
        </div>
        <div className="ml-3">
          <h3 className="text-sm font-medium text-red-800">{title}</h3>
          <div className="mt-2 text-sm text-red-700">
            <p>{message}</p>
          </div>
          {onRetry && (
            <div className="mt-4">
              <Button size="sm" variant="danger" onClick={onRetry}>Try Again</Button>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
