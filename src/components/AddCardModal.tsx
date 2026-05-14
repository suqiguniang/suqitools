import React, { useState } from 'react';
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

interface Props {
  visible: boolean;
  onClose: () => void;
  onSave: (card: Omit<CardItem, "id">) => void;
}

const AddCardModal: React.FC<Props> = ({ visible, onClose, onSave }) => {
  const [type, setType] = useState<'web' | 'wol'>('web');
  const [title, setTitle] = useState('');
  const [url, setUrl] = useState('');
  const [macAddress, setMacAddress] = useState('');
  const [ipAddress, setIpAddress] = useState('255.255.255.255');
  const [port, setPort] = useState('9');

  const handleSave = () => {
    if (!title.trim()) return;

    if (type === 'web' && !url.trim()) return;
    if (type === 'wol' && !macAddress.trim()) return;

    onSave({
      type,
      title: title.trim(),
      url: type === 'web' ? url.trim() : undefined,
      macAddress: type === 'wol' ? macAddress.trim() : undefined,
      ipAddress: type === 'wol' ? ipAddress.trim() : undefined,
      port: type === 'wol' ? parseInt(port, 10) || 9 : undefined,
    });

    setTitle('');
    setUrl('');
    setMacAddress('');
    setIpAddress('255.255.255.255');
    setPort('9');
    setType('web');
    onClose();
  };

  return (
    <Modal
      visible={visible}
      transparent
      animationType="slide"
      onRequestClose={onClose}
    >
      <View style={styles.overlay}>
        <View style={styles.container}>
          <View style={styles.header}>
            <Text style={styles.headerTitle}>添加卡片</Text>
            <TouchableOpacity onPress={onClose}>
              <Icon name="close" size={24} color="#333" />
            </TouchableOpacity>
          </View>

          <ScrollView style={styles.form}>
            <View style={styles.typeSelector}>
              <TouchableOpacity
                style={[styles.typeButton, type === 'web' && styles.typeButtonActive]}
                onPress={() => setType('web')}
              >
                <Icon name="web" size={20} color={type === 'web' ? '#fff' : '#666'} />
                <Text style={[styles.typeText, type === 'web' && styles.typeTextActive]}>
                  网页
                </Text>
              </TouchableOpacity>
              <TouchableOpacity
                style={[styles.typeButton, type === 'wol' && styles.typeButtonActive]}
                onPress={() => setType('wol')}
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
                    placeholder="AA:BB:CC:DD:EE:FF"
                    autoCapitalize="characters"
                  />
                </View>
                <View style={styles.inputGroup}>
                  <Text style={styles.label}>IP 地址 (可选)</Text>
                  <TextInput
                    style={styles.input}
                    value={ipAddress}
                    onChangeText={setIpAddress}
                    placeholder="255.255.255.255"
                  />
                </View>
                <View style={styles.inputGroup}>
                  <Text style={styles.label}>端口 (可选)</Text>
                  <TextInput
                    style={styles.input}
                    value={port}
                    onChangeText={setPort}
                    placeholder="9"
                    keyboardType="number-pad"
                  />
                </View>
              </>
            )}
          </ScrollView>

          <TouchableOpacity style={styles.saveButton} onPress={handleSave}>
            <Text style={styles.saveButtonText}>保存</Text>
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