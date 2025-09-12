package com.tencent.supersonic.auth.authentication.service;

import com.alibaba.fastjson2.JSON;
import com.alibaba.fastjson2.JSONObject;
import com.tencent.supersonic.auth.api.authentication.pojo.Organization;
import com.tencent.supersonic.auth.api.authentication.pojo.UserToken;
import com.tencent.supersonic.auth.api.authentication.request.UserReq;
import com.tencent.supersonic.auth.api.authentication.service.UserService;
import com.tencent.supersonic.auth.api.authentication.utils.UserHolder;
import com.tencent.supersonic.auth.authentication.utils.ComponentFactory;
import com.tencent.supersonic.common.config.SystemConfig;
import com.tencent.supersonic.common.pojo.User;
import com.tencent.supersonic.common.service.SystemConfigService;
import com.tencent.supersonic.common.util.HttpUtils;
import com.tencent.supersonic.common.util.JsonUtil;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.collections.MapUtils;
import org.apache.commons.lang3.StringUtils;
import org.springframework.stereotype.Service;
import org.springframework.util.CollectionUtils;

import java.util.*;

@Slf4j
@Service
public class UserServiceImpl implements UserService {

    private SystemConfigService sysParameterService;

    public UserServiceImpl(SystemConfigService sysParameterService) {
        this.sysParameterService = sysParameterService;
    }

    @Override
    public User getCurrentUser(HttpServletRequest httpServletRequest,
            HttpServletResponse httpServletResponse) {
        User user = UserHolder.findUser(httpServletRequest, httpServletResponse);
        if (user != null) {
            SystemConfig systemConfig = sysParameterService.getSystemConfig();
            if (!CollectionUtils.isEmpty(systemConfig.getAdmins())
                    && systemConfig.getAdmins().contains(user.getName())) {
                user.setIsAdmin(1);
            }
        }
        return user;
    }

    @Override
    public List<String> getUserNames() {
        return ComponentFactory.getUserAdaptor().getUserNames();
    }

    @Override
    public List<User> getUserList() {
        return ComponentFactory.getUserAdaptor().getUserList();
    }

    @Override
    public Set<String> getUserAllOrgId(String userName) {
        return ComponentFactory.getUserAdaptor().getUserAllOrgId(userName);
    }

    @Override
    public List<User> getUserByOrg(String key) {
        return ComponentFactory.getUserAdaptor().getUserByOrg(key);
    }

    @Override
    public List<Organization> getOrganizationTree() {
        return ComponentFactory.getUserAdaptor().getOrganizationTree();
    }

    @Override
    public void register(UserReq userReq) {
        ComponentFactory.getUserAdaptor().register(userReq);
    }

    @Override
    public void deleteUser(long userId) {
        ComponentFactory.getUserAdaptor().deleteUser(userId);
    }

    @Override
    public String login(UserReq userReq, HttpServletRequest request) {
        if (StringUtils.isNotBlank(userReq.getAuthKey())) {
            String authKey = userReq.getAuthKey();
            if (StringUtils.isNotBlank(authKey)) {
                // 请求ssoLogin接口获取登录用户
                String userId = null;
                try {
                    HashMap<String, String> headers = new HashMap<>();
                    headers.put("authorization", authKey);
                    String res = HttpUtils.get("http://xzzc.sdcxzc.cn/prod-api/system/user/profile/getSsoUser", headers);
                    JSONObject jsonObject = JSON.parseObject(res);
                    userId = jsonObject.getJSONObject("data").getJSONObject("loginUser").getJSONObject("sysUser").getString("userId");
                } catch (Exception e) {
                    log.error("单点登陆失败: {}",e.getMessage());
                }
                if (StringUtils.isNotBlank(userId)) {
                    UserToken userToken = ComponentFactory.getUserAdaptor().getUserToken(1L);
                    return userToken.getToken();
                }
            }
        }
        return ComponentFactory.getUserAdaptor().login(userReq, request);
    }

    @Override
    public String login(UserReq userReq, String appKey) {
        return ComponentFactory.getUserAdaptor().login(userReq, appKey);
    }

    @Override
    public String getPassword(String userName) {
        return ComponentFactory.getUserAdaptor().getPassword(userName);
    }

    @Override
    public void resetPassword(String userName, String password, String newPassword) {
        ComponentFactory.getUserAdaptor().resetPassword(userName, password, newPassword);
    }

    @Override
    public UserToken generateToken(String name, String userName, long expireTime) {
        return ComponentFactory.getUserAdaptor().generateToken(name, userName, expireTime);
    }

    @Override
    public List<UserToken> getUserTokens(String userName) {
        return ComponentFactory.getUserAdaptor().getUserTokens(userName);
    }

    @Override
    public UserToken getUserToken(Long id) {
        return ComponentFactory.getUserAdaptor().getUserToken(id);
    }

    @Override
    public void deleteUserToken(Long id) {
        ComponentFactory.getUserAdaptor().deleteUserToken(id);
    }
}
