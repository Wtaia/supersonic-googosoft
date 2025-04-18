import IconFont from '../../../components/IconFont';
import styles from './style.module.less';
import {Avatar} from "antd";
import React from "react";

const CopilotAvatar = () => {
  // return <IconFont type="icon-zhinengsuanfa" className={styles.leftAvatar} />;
  return <img src={"/webapp/fo-sd4.png"} style={{width:'4%'}} alt="智能问数"/>;
};

export default CopilotAvatar;
