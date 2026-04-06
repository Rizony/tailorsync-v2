import React, { forwardRef } from 'react';
import { cn } from '@/lib/utils';
import { colors } from '@/theme/colors';

export interface InputProps extends React.InputHTMLAttributes<HTMLInputElement> {
  label?: string;
  error?: string;
  helperText?: string;
  icon?: React.ReactNode;
}

const Input = forwardRef<HTMLInputElement, InputProps>(
  ({ className, label, error, helperText, icon, ...props }, ref) => {
    const hasError = !!error;
    const isDisabled = props.disabled;

    return (
      <div className="w-full">
        {label && (
          <label className="block text-sm font-medium text-gray-700 mb-1.5">
            {label}
          </label>
        )}
        <div className="relative rounded-md shadow-sm">
          {icon && (
            <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none text-gray-400">
              {icon}
            </div>
          )}
          <input
            ref={ref}
            className={cn(
              'block w-full rounded-md border text-gray-900 transition-colors bg-white px-3 py-2 sm:text-sm outline-none focus:ring-2 placeholder-gray-400',
              !!icon && 'pl-10',
              !hasError && !isDisabled && 'border-gray-300 focus:border-blue-500 focus:ring-blue-500',
              hasError && 'border-red-300 text-red-900 focus:border-red-500 focus:ring-red-500',
              isDisabled && 'bg-gray-50 text-gray-500 cursor-not-allowed border-gray-200',
              className
            )}
            {...props}
          />
        </div>
        {(error || helperText) && (
          <p
            className={cn(
              'mt-1.5 text-sm',
              error ? 'text-red-600' : 'text-gray-500'
            )}
          >
            {error || helperText}
          </p>
        )}
      </div>
    );
  }
);
Input.displayName = 'Input';

export { Input };
