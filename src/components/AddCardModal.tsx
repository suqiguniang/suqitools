import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  StyleSheet,
  Modal,
  TextInput,
  TouchableOpacity,
  ScrollView,
} from 'react-native';
import Icon from 'react-native-vector-icons/MaterialCommunityIcons';
import { CardItem } from '../types';
import { DEFAULT_MAC, DEFAULT_IP, DEFAULT_PORT } from '../wol';

interface Props {
  visible: boolean;
  onClose: () => void;
  onSave: (card: Omit<CardItem, "id">) => void;
  editCard?: CardItem | null;
}

const AddCardModal: React.FC<Props> = ({ visible, onClose, onSave, editCard }) => {
  const isEditing = !!editCard;
  
  const [type, setType] = useState<'web' | 'wol'>('web');
  const [title, setTitle] = useState('');
  const [url, setUrl] = useState('');
  const [macAddress, setMacAddress] = useState(DEFAULT_MAC);
  const [ipAddress, setIpAddress] = useState(DEFAULT_IP);
  const [port, setPort] = useState(DEFAULT_PORT.toString());

  // 当编辑模式或可见性改变时，重置表单
  useEffect(() => {
    if (visible) {
      if (editCard) {
        // 编辑模式：填充现有数据
        setType(editCard.type);
        setTitle(editCard.title || '');
        setUrl(editCard.url || '');
        setMacAddress(editCard.macAddress || DEFAULT_MAC);
        setIpAddress(editCard.ipAddress || DEFAULT_IP);
        setPort(editCard.port?.toString() || DEFAULT_PORT.toString());
      } else {
        // 新增模式：重置为默认值
        setType('web');
        setTitle('');
        setUrl('');
        setMacAddress(DEFAULT_MAC);
        setIpAddress(DEFAULT_IP);
        setPort(DEFAULT_PORT.toString());
      }
    }
  }, [visible, editCard]);

  const handleSave = () => {
    if (!title.trim()) return;

    if (type === 'web' && !url.trim()) return;
    if (type === 'wol' && !macAddress.trim()) return;

    onSave({
      type,
      title: title.trim(),
      url: type === 'web' ? url.trim() : undefined,
      macAddress: type === 'wol' ? macAddress.trim() : undefined,
      ipAddress: type === 'wol' ? ipAddress.trim() || DEFAULT_IP : undefined,
      port: type === 'wol' ? parseInt(port, 10) || DEFAULT_PORT : undefined,
    });

    onClose();
  };

  const handleClose = () => {
    onClose();
  };

  return (
    <Modal
      visible={visible}
      transparent
      animationType="slide"
      onRequestClose={handleClose}
    >
      <View style={styles.overlay}>
        <View style={styles.container}>
          <View style={styles.header}>
            <Text style={styles.headerTitle}>
              {isEditing ? '编辑卡片' : '添加卡片'}
            </Text>
            <TouchableOpacity onPress={handleClose}>
              <Icon name="close" size={24} color="#333" />
            </TouchableOpacity>
          </View>

          <ScrollView style={styles.form}>
            <View style={styles.typeSelector}>
              <TouchableOpacity
                style={[styles.typeButton, type === 'web' && styles.typeButtonActive]}
                onPress={() => setType('web')}
                disabled={isEditing}
              >
                <Icon name="web" size={20} color={type === 'web' ? '#fff' : '#666'} />
                <Text style={[styles.typeText, type === 'web' && styles.typeTextActive]}>
                  网页
                </Text>
              </TouchableOpacity>
              <TouchableOpacity
                style={[styles.typeButton, type === 'wol' && styles.typeButtonActive]}
                onPress={() => setType('wol')}
                disabled={isEditing}
              >
                <Icon name="power" size={20} color={type === 'wol' ? '#fff' : '#666'} />
                <Text style={[styles.typeText, type === 'wol' && styles.typeTextActive]}>
                  WOL
                </Text>
              </TouchableOpacity>
            </View>

            <View style={styles.inputGroup}>
              <Text style={styles.label}>标题</Text>
              <TextInput
                style={styles.input}
                value={title}
                onChangeText={setTitle}
                placeholder="输入卡片标题"
              />
            </View>

            {type === 'web' ? (
              <View style={styles.inputGroup}>
                <Text style={styles.label}>网址</Text>
                <TextInput
                  style={styles.input}
                  value={url}
                  onChangeText={setUrl}
                  placeholder="https://example.com"
                  keyboardType="url"
                  autoCapitalize="none"
                />
              </View>
            ) : (
              <>
                <View style={styles.inputGroup}>
                  <Text style={styles.label}>MAC 地址</Text>
                  <TextInput
                    style={styles.input}
                    value={macAddress}
                    onChangeText={setMacAddress}
                    placeholder="00:E0:4C:4D:1E:38"
                    autoCapitalize="characters"
                  />
                  <Text style={styles.hint}>默认: {DEFAULT_MAC}</Text>
                </View>
                <View style={styles.inputGroup}>
                  <Text style={styles.label}>IP 地址</Text>
                  <TextInput
                    style={styles.input}
                    value={ipAddress}
                    onChangeText={setIpAddress}
                    placeholder="192.168.1.5"
                  />
                  <Text style={styles.hint}>默认: {DEFAULT_IP}</Text>
                </View>
                <View style={styles.inputGroup}>
                  <Text style={styles.label}>端口</Text>
                  <TextInput
                    style={styles.input}
                    value={port}
                    onChangeText={setPort}
                    placeholder="9"
                    keyboardType="number-pad"
                  />
                  <Text style={styles.hint}>默认: {DEFAULT_PORT}</Text>
                </View>
              </>
            )}
          </ScrollView>

          <TouchableOpacity style={styles.saveButton} onPress={handleSave}>
            <Text style={styles.saveButtonText}>
              {isEditing ? '保存修改' : '保存'}
            </Text>
          </TouchableOpacity>
        </View>
      </View>
    </Modal>
  );
};

const styles = StyleSheet.create({
  overlay: {
    flex: 1,
    backgroundColor: 'rgba(0, 0, 0, 0.5)',
    justifyContent: 'flex-end',
  },
  container: {
    backgroundColor: '#fff',
    borderTopLeftRadius: 20,
    borderTopRightRadius: 20,
    maxHeight: '80%',
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    padding: 16,
    borderBottomWidth: 1,
    borderBottomColor: '#eee',
  },
  headerTitle: {
    fontSize: 18,
    fontWeight: '600',
    color: '#333',
  },
  form: {
    padding: 16,
  },
  typeSelector: {
    flexDirection: 'row',
    marginBottom: 16,
  },
  typeButton: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    padding: 12,
    borderRadius: 8,
    backgroundColor: '#f5f5f5',
    marginHorizontal: 4,
    gap: 8,
  },
  typeButtonActive: {
    backgroundColor: '#2196F3',
  },
  typeText: {
    fontSize: 14,
    color: '#666',
    fontWeight: '500',
  },
  typeTextActive: {
    color: '#fff',
  },
  inputGroup: {
    marginBottom: 16,
  },
  label: {
    fontSize: 14,
    fontWeight: '500',
    color: '#333',
    marginBottom: 6,
  },
  input: {
    borderWidth: 1,
    borderColor: '#ddd',
    borderRadius: 8,
    padding: 12,
    fontSize: 14,
    color: '#333',
  },
  hint: {
    fontSize: 12,
    color: '#999',
    marginTop: 4,
  },
  saveButton: {
    backgroundColor: '#2196F3',
    margin: 16,
    padding: 16,
    borderRadius: 12,
    alignItems: 'center',
  },
  saveButtonText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: '600',
  },
});

export default AddCardModal;