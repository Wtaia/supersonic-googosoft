import { useEffect, useState } from 'react';
import { useLocation } from '@umijs/max';
import { getToken } from '@/utils/utils';
import queryString from 'query-string';
import { Chat } from 'supersonic-chat-sdk';
import { AUTH_TOKEN_KEY } from "@/common/constants";
import { postUserLogin } from "@/pages/Login/services";

const ChatPage = () => {
  const location = useLocation();
  const [agentId, setAgentId] = useState(undefined);
  const [token, setToken] = useState(getToken() || '');

  useEffect(() => {
    const query = queryString.parse(location.search) || {};
    const { agentId } = query;

    if (agentId) {
      setAgentId(+agentId);
    }

    let paths = window.location.pathname.split('/');
    let path = paths[paths.length - 1];
    if (path.includes('auth-')) {
      const fetchToken = async () => {
        try {
          let newVar = await postUserLogin({ authKey: path.substring(path.indexOf('-') + 1) });
          localStorage.setItem(AUTH_TOKEN_KEY, newVar.data);
          setToken(newVar.data);
        } catch (error) {
          console.error("Error during login request:", error);
        }
      };
      fetchToken();
    }
  }, [location]);

  return (
    <Chat initialAgentId={agentId} token={token} isDeveloper />
  );
};

export default ChatPage;
