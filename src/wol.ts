import dgram from 'react-native-udp';

export const sendWOL = async (
  macAddress: string,
  ipAddress: string = '255.255.255.255',
  port: number = 9,
): Promise<boolean> => {
  return new Promise((resolve, reject) => {
    try {
      const cleanMac = macAddress.replace(/[:-]/g, '');
      
      if (cleanMac.length !== 12) {
        reject(new Error('Invalid MAC address format'));
        return;
      }

      const macBytes = [];
      for (let i = 0; i < 12; i += 2) {
        macBytes.push(parseInt(cleanMac.substr(i, 2), 16));
      }

      const magicPacketArray: number[] = [];
      
      for (let i = 0; i < 6; i++) {
        magicPacketArray.push(0xFF);
      }
      
      for (let i = 0; i < 16; i++) {
        for (let j = 0; j < 6; j++) {
          magicPacketArray.push(macBytes[j]);
        }
      }

      const magicPacket = Buffer.from(magicPacketArray);

      const socket = dgram.createSocket({ type: 'udp4' });
      
      socket.bind(0, () => {
        socket.setBroadcast(true);
        
        socket.send(
          magicPacket,
          0,
          magicPacket.length,
          port,
          ipAddress,
          (error: any) => {
            if (error) {
              socket.close();
              reject(error);
            } else {
              socket.close();
              resolve(true);
            }
          }
        );
      });
    } catch (error) {
      reject(error);
    }
  });
};