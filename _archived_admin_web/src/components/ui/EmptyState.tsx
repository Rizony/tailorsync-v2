import React from 'react';
import { cn } from '@/lib/utils';
import { Inbox } from 'lucide-react';

interface EmptyStateProps {
  title: string;
  description: string;
  icon?: React.ReactNode;
  action?: React.ReactNode;
  className?: string;
}

export function EmptyState({ title, description, icon, action, className }: EmptyStateProps) {
  return (
    <div className={cn("text-center py-12 px-4 rounded-xl border-2 border-dashed border-gray-200 bg-gray-50/50", className)}>
      <div className="mx-auto h-12 w-12 text-gray-400 flex items-center justify-center mb-4">
        {icon || <Inbox className="h-10 w-10 text-gray-300" />}
      </div>
      <h3 className="mt-2 text-sm font-semibold text-gray-900">{title}</h3>
      <p className="mt-1 text-sm text-gray-500 max-w-sm mx-auto">{description}</p>
      {action && (
        <div className="mt-6">
          {action}
        </div>
      )}
    </div>
  );
}
