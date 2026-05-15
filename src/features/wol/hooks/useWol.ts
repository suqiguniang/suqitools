import { useState, useCallback } from 'react';
import { sendWOL, validateMacAddress, WolOptions, DEFAULT_IP, isDeviceOnline } from '../../../services/wolService';

interface UseWolReturn {
  isLoading: boolean;
  error: string | null;
  success: boolean;
  sendWakeSignal: (options: WolOptions) => Promise<void>;
  reset: () => void;
}

export const useWol = (): UseWolReturn => {
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState(false);


  const sendWakeSignal = useCallback(async (options: WolOptions) => {
    setIsLoading(true);
    setError(null);
    setSuccess(false);

    try {
      if (!validateMacAddress(options.macAddress)) {
        throw new Error('无效的 MAC 地址格式');
      }

      await sendWOL(
        options.macAddress,
        options.ipAddress,
        options.port
      );
      // 检查设备是否已经在线
      const ipToCheck = options.ipAddress || DEFAULT_IP;
        const online = await isDeviceOnline(ipToCheck);
      setSuccess(online);
      if (!online) {
        setError('设备未响应，可能仍未开机');
      }
    } catch (err: any) {
      setError(err.message || '发送唤醒信号失败');
    } finally {
      setIsLoading(false);
    }
  }, []);

  const reset = useCallback(() => {
    setIsLoading(false);
    setError(null);
    setSuccess(false);
  }, []);

  return {
    isLoading,
    error,
    success,
    sendWakeSignal,
    reset,
  };
};
