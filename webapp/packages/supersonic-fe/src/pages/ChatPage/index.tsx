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
    const publicKey = 'eyJhbGciOiJIUzUxMiJ9.eyJ0b2tlbl91c2VyX2VtYWlsIjoiYWRtaW5AeHguY29tIiwidG9rZW5fdXNlcl9pZCI6MSwidG9rZW5fdXNlcl9kaXNwbGF5X25hbWUiOiJhZG1pbiIsInRva2VuX2NyZWF0ZV90aW1lIjoxNzQ0OTU0NTYxMDQxLCJ0b2tlbl9pc19hZG1pbiI6MSwidG9rZW5fdXNlcl9uYW1lIjoiYWRtaW4iLCJ0b2tlbl91c2VyX3Bhc3N3b3JkIjoiYzNWd1pYSnpiMjVwWTBCaWFXTnZiZGt0SkpZV3c2QTNyRW1CVVB6Ym4vNkROZVluRCt5M21Bd0RLRU1TM0tWVCIsInN1YiI6ImFkbWluIiwiZXhwIjoxODQ2MDIyMzk5fQ.nz_PRQScrEdctGU0uu0_s72umns4JLuZ5AdU-baflbUEsuzOi0p1kPStOw6bfRkMC84Li_ljIbNfPgE93hJyYQ';
    const query = queryString.parse(location.search) || {};
    const { agentId } = query;

    if (agentId) {
      setAgentId(+agentId);
    }

    let paths = window.location.pathname.split('/');
    let path = paths[paths.length - 1];
    if (path.includes('auth-')) {
      // const fetchToken = async () => {
      //   try {
      //     let newVar = await postUserLogin({ authKey: path.substring(path.indexOf('-') + 1) });
      //     localStorage.setItem(AUTH_TOKEN_KEY, newVar);
      //     setToken(newVar);
      //   } catch (error) {
      //     console.error("Error during login request:", error);
      //   }
      // };
      // fetchToken();
      localStorage.setItem(AUTH_TOKEN_KEY, publicKey);
      setToken(publicKey);
    }
  }, [location]);

  return (
    <Chat initialAgentId={agentId} token={token} isDeveloper />
  );
};

export default ChatPage;
