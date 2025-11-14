import React from 'react';

interface LogoEconeuraProps {
  size?: 'sm' | 'md' | 'lg' | 'xl';
  showText?: boolean;
  className?: string;
  darkMode?: boolean;
}

export function LogoEconeura({ 
  size = 'md', 
  showText = true, 
  className = '',
  darkMode = false 
}: LogoEconeuraProps) {
  const sizeClasses = {
    sm: 'h-10',
    md: 'h-16', 
    lg: 'h-20',
    xl: 'h-24'
  };

  const textSizes = {
    sm: 'text-lg',
    md: 'text-xl',
    lg: 'text-2xl', 
    xl: 'text-3xl'
  };

  return (
    <div className={`flex items-center gap-3 group ${className}`}>
      {/* Logo oficial ECONEURA con efectos PREMIUM */}
      <div className="relative">
        {/* Glow animado de fondo */}
        <div 
          className="absolute inset-0 rounded-full blur-xl opacity-0 group-hover:opacity-70 transition-all duration-700"
          style={{
            background: 'radial-gradient(circle, rgba(251,191,36,0.6) 0%, rgba(59,130,246,0.4) 50%, transparent 70%)',
            animation: 'pulse 3s ease-in-out infinite'
          }}
        />
        
        {/* Anillo exterior giratorio */}
        <div 
          className="absolute inset-0 rounded-full opacity-0 group-hover:opacity-100 transition-all duration-500"
          style={{
            border: '2px solid transparent',
            borderImage: 'linear-gradient(45deg, #fbbf24, #3b82f6, #10b981) 1',
            animation: 'spin 8s linear infinite',
            transform: 'scale(1.2)'
          }}
        />
        
        {/* Contenedor con glassmorphism */}
        <div 
          className="relative rounded-full p-1 transition-all duration-500 group-hover:scale-110 group-hover:rotate-[5deg]"
          style={{
            background: darkMode 
              ? 'linear-gradient(135deg, rgba(59,130,246,0.3), rgba(251,191,36,0.2))' 
              : 'linear-gradient(135deg, rgba(59,130,246,0.15), rgba(251,191,36,0.1))',
            backdropFilter: 'blur(10px)',
            boxShadow: darkMode
              ? '0 8px 32px rgba(251,191,36,0.3), 0 0 0 1px rgba(59,130,246,0.2)'
              : '0 8px 32px rgba(59,130,246,0.2), 0 0 0 1px rgba(251,191,36,0.1)',
            transform: 'translateZ(0)'
          }}
        >
          <img 
            src="/logo-econeura.png"
            alt="ECONEURA - Árbol Neuronal" 
            className={`${sizeClasses[size]} w-auto transition-all duration-500`}
            style={{
              filter: darkMode 
                ? 'brightness(1.15) contrast(1.1) drop-shadow(0 4px 12px rgba(251,191,36,0.4))' 
                : 'brightness(1.05) contrast(1.15) drop-shadow(0 4px 12px rgba(59,130,246,0.3))',
              transform: 'translateZ(20px)'
            }}
          />
        </div>
        
        {/* Destellos de luz */}
        <div 
          className="absolute top-0 left-0 w-2 h-2 rounded-full bg-amber-400 opacity-0 group-hover:opacity-100 blur-sm"
          style={{
            animation: 'ping 2s cubic-bezier(0, 0, 0.2, 1) infinite'
          }}
        />
        <div 
          className="absolute bottom-0 right-0 w-2 h-2 rounded-full bg-blue-400 opacity-0 group-hover:opacity-100 blur-sm"
          style={{
            animation: 'ping 2s cubic-bezier(0, 0, 0.2, 1) infinite 1s'
          }}
        />
      </div>
      
      {/* Texto ECONEURA con efectos premium */}
      {showText && (
        <div className="relative group">
          {/* Sombra inferior para relieve premium */}
          <span
            className={`absolute top-[2px] left-[1px] ${textSizes[size]} font-black tracking-tight text-slate-500/60 blur-[0.5px]`}
            style={{
              fontFamily: '"Inter", "SF Pro Display", system-ui, -apple-system, sans-serif',
              letterSpacing: '-0.03em',
              fontWeight: 900
            }}
            aria-hidden="true"
          >
            ECONEURA
          </span>

          {/* Texto principal con efectos premium */}
          <span
            className={`relative ${textSizes[size]} font-black tracking-tight transition-all duration-300 group-hover:scale-105 ${
              darkMode
                ? 'bg-gradient-to-r from-emerald-400 via-teal-400 to-cyan-400 bg-clip-text text-transparent'
                : 'text-slate-900'
            }`}
            style={{
              fontFamily: '"Inter", "SF Pro Display", system-ui, -apple-system, sans-serif',
              letterSpacing: '-0.03em',
              fontWeight: 900,
              textShadow: darkMode
                ? '0 2px 8px rgba(16, 185, 129, 0.4), 0 4px 16px rgba(16, 185, 129, 0.2), 0 8px 32px rgba(16, 185, 129, 0.1)'
                : '0 2px 0 rgba(255, 255, 255, 0.9), 0 -1px 0 rgba(0, 0, 0, 0.15), 0 3px 8px rgba(0, 0, 0, 0.08), 0 6px 16px rgba(0, 0, 0, 0.04)',
              filter: 'contrast(1.1) brightness(1.05)'
            }}
          >
            ECONEURA
          </span>
          
          {/* Efecto de brillo sutil */}
          <div className={`absolute inset-0 rounded-lg opacity-0 group-hover:opacity-20 transition-opacity duration-500 ${
            darkMode ? 'bg-gradient-to-r from-emerald-400 to-cyan-400' : 'bg-gradient-to-r from-emerald-500 to-cyan-500'
          } blur-sm`} />
        </div>
      )}
    </div>
  );
}
