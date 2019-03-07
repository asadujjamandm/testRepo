require 'utils'
require 'exceptions'

class ErpSync
  def self.get_sync_status(uid, pwd)
    syncs = {}
    resp = NsiServices.get(NSI_SERVICE_SYNC_STATUS, {'userid' => uid, 'password' => pwd})
    return syncs if resp.nil? || resp['syncs'].nil? || resp['syncs']['sync'].nil?
    i=0
    if resp['syncs']['sync'].is_a?(Array)
      resp['syncs']['sync'].each do |s|
        values=s.split(',').collect! { |x| Utils.strip_str(x) }
        syncs[i]=SyncStatus.get(values)
        i+=1
      end
    else
      values=resp['syncs']['sync'].split(',').collect! { |x| Utils.strip_str(x) }
      syncs[0]=SyncStatus.get(values)
    end
    return syncs
  end

  def self.sync(service, uid, pwd)
    resp = NsiServices.get(service, {'userid' => uid, 'password' => pwd})
    return NsiServices.resp_success_with_code_message(resp)
  end

  def self.get_recent_syncs(syncs)
    return get_recent_sync(syncs, NSI_SYNC_KEY_ERP), get_recent_sync(syncs, NSI_SYNC_KEY_DEVICE)
  end

  private
  def self.get_recent_sync(syncs, key)
    s = syncs.select do |k, v|
      v.type == key
    end

    if s.nil? || s.size == 0
      return nil
    else
      return s.to_a[0].to_a[1]
    end
  end
end