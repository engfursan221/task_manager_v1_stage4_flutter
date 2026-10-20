import React, { createContext, useContext, useEffect, useState } from 'react';

interface AuthContextType {
  isAuthenticated: boolean;
  userEmail: string;
  isLoading: boolean;
  login: (email: string, password: string) => Promise<{ success: boolean; error?: string }>;
  logout: () => void;
  demoEmail: string;
  demoPassword: string;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export const DEMO_EMAIL = 'student@university.edu';
export const DEMO_PASSWORD = 'password123';

const KEY_IS_LOGGED_IN = 'is_logged_in';
const KEY_USER_EMAIL = 'user_email';

export const AuthProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [isAuthenticated, setIsAuthenticated] = useState<boolean>(false);
  const [userEmail, setUserEmail] = useState<string>(DEMO_EMAIL);
  const [isLoading, setIsLoading] = useState<boolean>(true);

  useEffect(() => {
    // Startup check (similar to SplashScreen in Flutter)
    const timer = setTimeout(() => {
      const loggedIn = localStorage.getItem(KEY_IS_LOGGED_IN) === 'true';
      const savedEmail = localStorage.getItem(KEY_USER_EMAIL);

      if (loggedIn) {
        setIsAuthenticated(true);
        setUserEmail(savedEmail || DEMO_EMAIL);
      } else {
        setIsAuthenticated(false);
      }
      setIsLoading(false);
    }, 600);

    return () => clearTimeout(timer);
  }, []);

  const login = async (email: string, password: string): Promise<{ success: boolean; error?: string }> => {
    const cleanEmail = email.trim();
    const cleanPassword = password.trim();

    if (!cleanEmail || !cleanPassword) {
      return { success: false, error: 'يرجى إدخال اسم المستخدم/البريد الإلكتروني وكلمة المرور' };
    }

    if (cleanPassword.length < 4) {
      return { success: false, error: 'يجب أن تتكون كلمة المرور من 4 أحرف على الأقل.' };
    }

    // Demo validation: accepts demo credentials or any email with 4+ char password
    const isValid =
      (cleanEmail === DEMO_EMAIL && cleanPassword === DEMO_PASSWORD) ||
      (cleanEmail.length > 0 && cleanPassword.length >= 4);

    if (isValid) {
      localStorage.setItem(KEY_IS_LOGGED_IN, 'true');
      localStorage.setItem(KEY_USER_EMAIL, cleanEmail);
      setIsAuthenticated(true);
      setUserEmail(cleanEmail);
      return { success: true };
    }

    return { success: false, error: 'بيانات الدخول غير صحيحة.' };
  };

  const logout = () => {
    localStorage.removeItem(KEY_IS_LOGGED_IN);
    localStorage.removeItem(KEY_USER_EMAIL);
    setIsAuthenticated(false);
  };

  return (
    <AuthContext.Provider
      value={{
        isAuthenticated,
        userEmail,
        isLoading,
        login,
        logout,
        demoEmail: DEMO_EMAIL,
        demoPassword: DEMO_PASSWORD,
      }}
    >
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
};
