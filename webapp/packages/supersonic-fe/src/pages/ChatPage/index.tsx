import {useEffect, useState} from 'react';
import {history, useLocation} from '@umijs/max';
import queryString from 'query-string';
import {Chat} from 'supersonic-chat-sdk';
import {AUTH_TOKEN_KEY} from '@/common/constants';
import {postUserLogin} from '@/pages/Login/services';
import {Spin, Typography} from 'antd';

const { Text } = Typography;

const ChatPage = () => {
  const location = useLocation();
  const [agentId, setAgentId] = useState<number | undefined>(undefined);
  const [token, setToken] = useState<string>('');
  const [loading, setLoading] = useState<boolean>(true);

  useEffect(() => {
    const query = queryString.parse(location.search);
    const { agentId: agentIdParam } = query;

    if (agentIdParam) {
      setAgentId(+agentIdParam);
    }
    const paths = location.pathname.split('/');
    const lastPath = paths[paths.length - 1];
    const hasAuthPath = lastPath.includes('auth-');

    const cleanedPathname = hasAuthPath
      ? location.pathname.replace(/\/auth-[^\/]+$/, '')
      : location.pathname;

    const initializeToken = async () => {
      if (hasAuthPath) {
        try {
          const authKey = lastPath.substring(lastPath.indexOf('-') + 1);
          const response = await postUserLogin({ authKey });
          const newToken = response.data;
          localStorage.setItem(AUTH_TOKEN_KEY, newToken);
          setToken(newToken);
        } catch (error) {
          console.error('Error during login request:', error);
        }
      }

      history.replace({
        pathname: cleanedPathname,
        search: location.search,
      });

      setLoading(false);
    };
    initializeToken();
  }, [location]);

  if (loading) {
    return (
      <div
        style={{
          display: 'flex',
          flexDirection: 'column',
          justifyContent: 'center',
          alignItems: 'center',
          height: '100vh',
        }}
      >
        <Spin size="large" />
        <Text type="secondary" style={{ marginTop: 16 }}>
          正在登录...
        </Text>
      </div>
    );
  }

  return <Chat initialAgentId={agentId} token={token} isDeveloper isNewConversation={true} />;
};

export default ChatPage;
