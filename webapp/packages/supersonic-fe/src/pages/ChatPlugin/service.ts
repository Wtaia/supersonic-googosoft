import { request } from 'umi';
import { DimensionType, ModelType, PluginType } from './type';

export function savePlugin(params: Partial<PluginType>) {
  return request<Result<any>>(`${process.env.CHAT_API_BASE_URL}plugin`, {
    method: params.id ? 'PUT' : 'POST',
    data: params,
  });
}

export function getPluginList(filters?: any) {
  return request<Result<any[]>>(`${process.env.CHAT_API_BASE_URL}plugin/query`, {
    method: 'POST',
    data: filters,
  });
}

export function deletePlugin(id: number) {
  return request<Result<any>>(`${process.env.CHAT_API_BASE_URL}plugin/${id}`, {
    method: 'DELETE',
  });
}

export function getModelList() {
  return request<Result<ModelType[]>>(`${process.env.CHAT_API_BASE_URL}conf/getDomainDataSetTree`, {
    method: 'GET',
  });
}

export function getDataSetSchema(dataSetId: number) {
  return request<Result<{ list: DimensionType[] }>>(
    `${process.env.CHAT_API_BASE_URL}conf/getDataSetSchema/${dataSetId}`,
    {
      method: 'GET',
    },
  );
}
