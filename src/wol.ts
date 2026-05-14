import dgram from 'react-native-udp';

const DEFAULT_MAC = '00:e0:4c:4d:1e:38';
const DEFAULT_IP = '192.168.1.5';
const DEFAULT_PORT = 9;

export { DEFAULT_MAC, DEFAULT_IP, DEFAULT_PORT };

export const sendWOL = async (
  macAddress: string,
  ipAddress: string = DEFAULT_IP,
  port: number = DEFAULT_PORT,
): Promise<boolean> => {
  return new Promise((resolve, reject) => {
    try {
      // 清理MAC地址，移除分隔符
      const cleanMac = macAddress.replace(/[:-]/g, '').toLowerCase();
      
      if (cleanMac.length !== 12) {
        reject(new Error('Invalid MAC address format. Expected format: AA:BB:CC:DD:EE:FF'));
        return;
      }

      // 验证MAC地址只包含有效的十六进制字符
      if (!/^[0-9a-f]{12}$/.test(cleanMac)) {
        reject(new Error('Invalid MAC address characters'));
        return;
      }

      // 将MAC地址转换为字节数组
      const macBytes: number[] = [];
      for (let i = 0; i < 12; i += 2) {
        macBytes.push(parseInt(cleanMac.substring(i, i + 2), 16));
      }

      // 构建Magic Packet
      const magicPacket: number[] = [];
      
      // 前6个字节是0xFF
      for (let i = 0; i < 6; i++) {
        magicPacket.push(0xFF);
      }
      
      // 重复MAC地址16次
      for (let i = 0; i < 16; i++) {
        for (let j = 0; j < 6; j++) {
          magicPacket.push(macBytes[j]);
        }
      }

      // 创建Buffer
      const buffer = Buffer.from(magicPacket);

      // 创建UDP socket
      const socket = dgram.createSocket({ type: 'udp4' });
      
      // 设置超时
      const timeout = setTimeout(() => {
        socket.close();
        reject(new Error('WOL request timeout'));
      }, 5000);
      
      socket.once('error', (error) => {
        clearTimeout(timeout);
        socket.close();
        reject(error);
      });

      socket.bind(0, () => {
        try {
          socket.setBroadcast(true);
          
          socket.send(
            buffer,
            0,
            buffer.length,
            port,
            ipAddress,
            (error: any) => {
              clearTimeout(timeout);
              if (error) {
                socket.close();
                reject(error);
              } else {
                socket.close();
                resolve(true);
              }
            }
          );
        } catch (error) {
          clearTimeout(timeout);
          socket.close();
          reject(error);
        }
      });
    } catch (error) {
      reject(error);
    }
  });
};