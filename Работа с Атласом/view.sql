create or replace view v_rw_project_version as
with user_group_role as
 (select ugr.group_role_id,
         ugr.role_id
    from t_user_group_role ugr
   where ugr.user_id = pkg_user.getiduser),
user_access as
 (select x.value,
         t.rfr as dict_id,
         ugr.group_role_id,
         ugr.role_id
    from user_group_role ugr
    join t9922a9 t on ugr.role_id = t.vlu
    left join (select agr.group_role_id,
                     ua.value,
                     ua.dict_id
                from t_access_group_role agr,
                     t_user_access       ua
               where agr.access_id = ua.id) x
      on ugr.group_role_id = x.group_role_id
     and rfr = x.dict_id)
select vp.key as project_version_id,
       vp.name as project_version_name,
       k.key as project_id,
       vp.direction_id,
       vp.curate_direction_id,
       vp.program_id,
       vp.bn_id,
       vp.be_spo_id,
       vp.be_id,
       k.name as project_name,
       k.project_code,
       k.sort_project,
       k.type_id as project_type_id,
       vp.step_project_id,
       k.parent_key as parent_project_id,
       k.init_year,
       k.CREATE_USER_ID,
       k.create_date,
       k.monitoring_status_id,
       vp.project_manager_id,
       '/project-management/project-register/information/general?project=' || vp.key as href,
       cast(multiset (select r.role_id
               from user_group_role r
              where exists (select 1
                       from user_access aa
                      where aa.dict_id = 9468 /*osp_dict_keys.c_id_dict_rw_sort_project*/
                        and nvl(aa.value, k.sort_project) = k.sort_project
                        and aa.group_role_id = r.group_role_id)
                and exists (select 1
                       from user_access aa
                      where aa.dict_id = 9471 /*osp_dict_keys.c_id_dict_rw_project_step*/
                        and coalesce(aa.value, vp.step_project_id, -1) = nvl(vp.step_project_id, -1)
                        and aa.group_role_id = r.group_role_id)
                and exists (select 1
                       from user_access aa
                      where aa.dict_id = 9462 /*osp_dict_keys.c_id_dict_rw_project*/
                        and nvl(aa.value, k.key) = k.key
                        and aa.group_role_id = r.group_role_id)
                and exists (select 1
                       from user_access aa
                      where aa.dict_id = 10540 /*osp_dict_keys.c_id_dict_rw_curate_direction*/
                        and coalesce(aa.value, vp.curate_direction_id, -1) = nvl(vp.curate_direction_id, -1)
                        and aa.group_role_id = r.group_role_id)
                and exists (select 1
                       from user_access aa
                      where aa.dict_id = 10840 /*osp_dict_keys.c_id_dict_rw_bn*/
                        and coalesce(aa.value, vp.bn_id, -1) = nvl(vp.bn_id, -1)
                        and aa.group_role_id = r.group_role_id)
                and exists (select 1
                       from user_access aa
                      where aa.dict_id = 9765 /*osp_dict_keys.c_id_dict_be*/
                        and coalesce(aa.value, vp.be_id, -1) = nvl(vp.be_id, -1)
                        and aa.group_role_id = r.group_role_id)
                and exists (select 1
                       from user_access aa
                      where aa.dict_id = 10845 /*osp_dict_keys.c_id_dict_mi_oe*/
                        and coalesce(aa.value, vp.be_spo_id, -1) = nvl(vp.be_spo_id, -1)
                        and aa.group_role_id = r.group_role_id)) as t_dim_elements) as role_id
  from t9465 vp,
       t9462 k
 where vp.project_id = k.key
   and k.is_deleted = 0;
