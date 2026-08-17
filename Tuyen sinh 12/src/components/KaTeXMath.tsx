import React from 'react';
import katex from 'katex';

interface KaTeXMathProps {
  content: string;
  className?: string;
}

export const KaTeXMath: React.FC<KaTeXMathProps> = ({ content, className = '' }) => {
  // Parse math expressions delimited by $...$ (inline) or $$...$$ (display)
  const renderFormattedContent = (text: string) => {
    if (!text) return null;

    // Split by $$...$$ first, then by $...$
    const parts = text.split(/(\$\$[\s\S]*?\$\$|\$[^\$]+?\$)/g);

    return parts.map((part, index) => {
      if (part.startsWith('$$') && part.endsWith('$$')) {
        const math = part.slice(2, -2).trim();
        try {
          const html = katex.renderToString(math, { displayMode: true, throwOnError: false });
          return (
            <div
              key={index}
              className="my-2 overflow-x-auto text-center"
              dangerouslySetInnerHTML={{ __html: html }}
            />
          );
        } catch (err) {
          return <code key={index} className="text-rose-500">{part}</code>;
        }
      } else if (part.startsWith('$') && part.endsWith('$')) {
        const math = part.slice(1, -1).trim();
        try {
          const html = katex.renderToString(math, { displayMode: false, throwOnError: false });
          return (
            <span
              key={index}
              className="inline-block px-1"
              dangerouslySetInnerHTML={{ __html: html }}
            />
          );
        } catch (err) {
          return <code key={index} className="text-rose-500">{part}</code>;
        }
      }
      return <span key={index}>{part}</span>;
    });
  };

  return <div className={`inline-leading-relaxed ${className}`}>{renderFormattedContent(content)}</div>;
};
