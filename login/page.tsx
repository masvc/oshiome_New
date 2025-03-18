     // app/layout.tsx
     import React from 'react';

     const Layout = ({ children }) => {
       return (
         <div>
           <header>ヘッダー</header>
           <main>{children}</main>
           <footer>フッター</footer>
         </div>
       );
     };

     export default Layout;