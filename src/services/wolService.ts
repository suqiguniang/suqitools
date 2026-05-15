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
 * 检测设备是否在线（简易实现）
 * 使用 HTTP GET 请求尝试连接目标 IP，默认超时 3 秒。
 * 适用于目标设备上有 HTTP 服务的场景。
 */
export const isDeviceOnline = async (
  ipAddress: string,
  timeoutMs: number = 3000,
): Promise<boolean> => {
  try {
    const controller = new AbortController();
    const timeout = setTimeout(() => controller.abort(), timeoutMs);
    const response = await fetch(`http://${ipAddress}`, {
      method: 'GET',
      signal: controller.signal as any,
    });
    clearTimeout(timeout);
    return response.ok;
  } catch {
    return false;
  }
};

/**
 * 扫描局域网设备（IP 范围）并返回在线 IP 列表。
 * 这里实现一个非常简易的扫描：遍历给定的 IP 前缀（如 192.168.1）
 * 对每个 IP 发起 HTTP 请求（或任意端口的 TCP 连接），并收集成功的 IP。
 * 仅用于演示，实际项目可使用更高效的原生实现（如 AwakeOnLANMobile 中的 C++ 模块）。
 */
export const scanNetwork = async (
  baseIp: string, // e.g. "192.168.1"
  start: number = 1,
  end: number = 254,
  timeoutMs: number = 3000,
): Promise<string[]> => {
  const onlineIps: string[] = [];
  const promises: Promise<void>[] = [];
  for (let i = start; i <= end; i++) {
    const ip = `${baseIp}.${i}`;
    const p = isDeviceOnline(ip, timeoutMs).then(isOnline => {
      if (isOnline) onlineIps.push(ip);
    });
    promises.push(p);
  }
  await Promise.all(promises);
  return onlineIps;
};

/**
 * 验证 MAC 地址格式
 */
export const validateMacAddress = (mac: string): boolean => {
  const cleanMac = mac.replace(/[:-]/g, '').toLowerCase();
  return cleanMac.length === 12 && /^[0-9a-f]{12}$/.test(cleanMac);
};
