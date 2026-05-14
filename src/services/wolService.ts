import { wake } from 'react-native-wake-on-lan';

export const DEFAULT_MAC = '00:e0:4c:4d:1e:38';
export const DEFAULT_IP = '192.168.1.255';
export const DEFAULT_PORT = 9;

export interface WolOptions {
  macAddress: string;
  ipAddress?: string;
  port?: number;
}

/**
 * 发送 WOL 魔术包
 * @param macAddress MAC 地址，格式: AA:BB:CC:DD:EE:FF 或 AA-BB-CC-DD-EE-FF
 * @param ipAddress 广播地址，默认为 192.168.1.255
 * @param port 端口，默认为 9
 */
export const sendWOL = async (
  macAddress: string,
  ipAddress: string = DEFAULT_IP,
  port: number = DEFAULT_PORT,
): Promise<void> => {
  const cleanMac = macAddress.replace(/[:-]/g, '').toLowerCase();

  if (cleanMac.length !== 12) {
    throw new Error('Invalid MAC address format. Expected: AA:BB:CC:DD:EE:FF');
  }

  if (!/^[0-9a-f]{12}$/.test(cleanMac)) {
    throw new Error('Invalid MAC address characters');
  }

  const formattedMac = cleanMac.match(/.{2}/g)?.join(':') || cleanMac;

  await wake(formattedMac, {
    address: ipAddress,
    port,
  });
};

/**
 * 验证 MAC 地址格式
 */
export const validateMacAddress = (mac: string): boolean => {
  const cleanMac = mac.replace(/[:-]/g, '').toLowerCase();
  return cleanMac.length === 12 && /^[0-9a-f]{12}$/.test(cleanMac);
};
