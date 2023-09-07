import Web3 from "web3";
import ChatRoomABI from "./ChatRoomABI.json";
import CryptoJS from "crypto-js";
import ipfsClient from "ipfs-http-client";

const web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:8545"));
const chatRoom = new web3.eth.Contract(ChatRoomABI, "Contract_Address_Here");
const ipfs = ipfsClient({ host: "localhost", port: "5001", protocol: "http" });

// Room Management
const createRoom = async (roomId) => {
  const accounts = await web3.eth.getAccounts();
  await chatRoom.methods
    .createRoom(web3.utils.sha3(roomId))
    .send({ from: accounts[0] });
};

const joinRoom = async (roomId) => {
  const accounts = await web3.eth.getAccounts();
  const message = `Join room: ${roomId}`;
  const signature = await web3.eth.personal.sign(
    message,
    accounts[0],
    "password"
  );
  await chatRoom.methods
    .joinRoom(web3.utils.sha3(roomId), signature)
    .send({ from: accounts[0] });
};

// Message Encryption/Decryption
const symmetricEncrypt = (message, key) => {
  return CryptoJS.AES.encrypt(message, key).toString();
};

const symmetricDecrypt = (cipherText, key) => {
  const bytes = CryptoJS.AES.decrypt(cipherText, key);
  return bytes.toString(CryptoJS.enc.Utf8);
};

// File Upload/Download
const uploadFile = async (file, key) => {
  const encryptedFile = symmetricEncrypt(file, key);
  const { path } = await ipfs.add(encryptedFile);
  return path;
};

const downloadFile = async (ipfsHash, key) => {
  const encryptedFile = await ipfs.cat(ipfsHash);
  return symmetricDecrypt(encryptedFile, key);
};

// Paid Features
const increaseFileSize = async (roomId) => {
  const accounts = await web3.eth.getAccounts();
  await chatRoom.methods
    .increaseFileSize(web3.utils.sha3(roomId))
    .send({ from: accounts[0], value: web3.utils.toWei("0.0001", "ether") });
};
