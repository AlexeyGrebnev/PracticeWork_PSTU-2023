create or replace package body pkg_rw_project is

  c_head_id_name             constant number := 1; --Элемент шапки: Наименование
  c_head_id_sort_project     constant number := 2; --Элемент шапки: Вид проекта
  c_head_id_init_year        constant number := 3; --Элемент шапки: Год инициации проекта
  c_head_id_project_code     constant number := 4; --Элемент шапки: Код проекта
  c_head_id_step             constant number := 5; --Элемент шапки: Этап
  c_head_id_active           constant number := 6; --Элемент шапки: Актив
  c_head_id_deposit          constant number := 7; --Элемент шапки: Месторождение
  c_head_id_project_manager  constant number := 8; --Элемент шапки: РП
  c_head_id_direction        constant number := 9; --Элемент шапки: Дирекция
  c_head_id_curate_direction constant number := 10; --Элемент шапки: Курирующая дирекция
  c_head_id_program          constant number := 11; --Элемент шапки: Программа
  c_head_id_bn               constant number := 12; --Элемент шапки: БН
  c_head_id_be_spo           constant number := 13; --Элемент шапки: ОЕ
  c_head_id_be               constant number := 14; --Элемент шапки: БЕ
  c_head_id_type_project     constant number := 15; --Элемент шапки: Тип
  c_head_id_lu               constant number := 16; --Элемент шапки: ЛУ
  c_head_id_parent_project   constant number := 17; --Элемент шапки: Родительский проект
  c_head_id_open             constant number := 18; --Элемент шапки: возможность открывать проект
  c_head_id_monitoring       constant number := 19; --Элемент шапки: Статус мониторинга
  c_head_id_date             constant number := 20; --Элемент шапки: Дата добавления проекта(студентов)
  c_head_id_who             constant number := 21; --Элемент шапки: Кто добавил(студентов)
  

  --создание проекта
  procedure create_project(p_project in out typ_project) as
    l_block_kpi            typ_rw_project_data_block;
    l_block_info_project   typ_rw_project_data_block;
    l_block_prj_potentials typ_rw_project_data_block;
    l_block_param_project  typ_rw_project_data_block;
    l_block_step_project   typ_rw_project_data_block;
  begin
    p_project.check_project;
  
    p_project.project_id              := t9462$seq.nextval;
    p_project.main_project_version_id := t9465$seq.nextval;
  
    if p_project.auto_project_code = 1
    then
      generate_project_code(p_project_type_id => p_project.type_project_id,
                            p_sort_project_id => p_project.sort_project,
                            p_init_year       => p_project.init_year,
                            p_code            => p_project.project_code);
    end if;
  
    insert into t9462
      (key,
       name,
       ord,
       project_code,
       sort_project,
       type_id,
       auto_code,
       parent_key,
       is_deleted,
       init_year,
       monitoring_status_id, 
       CREATE_DATE,
       CREATE_USER_ID)
    values
      (p_project.project_id,
       '-',
       p_project.project_id,
       p_project.project_code,
       p_project.sort_project,
       p_project.type_project_id,
       nvl(p_project.auto_project_code, 0),
       p_project.parent_project_id,
       0,
       p_project.init_year,
       p_project.monitoring_status_id,
       trunc(sysdate),
       pkg_user.getiduser);
  
    insert into t9465
      (key,
       name,
       ord,
       project_id,
       step_project_id,
       project_manager_id,
       curate_direction_id,
       program_id,
       bn_id,
       be_spo_id,
       be_id,
       direction_id)
    values
      (p_project.main_project_version_id,
       p_project.name,
       p_project.main_project_version_id,
       p_project.project_id,
       p_project.step_id,
       p_project.project_manager_id,
       p_project.curate_direction_id,
       p_project.program_id,
       p_project.bn_id,
       p_project.be_spo_id,
       p_project.be_id,
       p_project.direction_id);
  
    insert into t9465a11
      (key,
       rfr,
       idx,
       vlu)
      select t9465a11$seq.nextval,
             p_project.main_project_version_id,
             rownum,
             column_value
        from table(wrapper_dim_elements(p_project.active_id));
  
    insert into t9465a12
      (key,
       rfr,
       idx,
       vlu)
      select t9465a12$seq.nextval,
             p_project.main_project_version_id,
             rownum,
             column_value
        from table(wrapper_dim_elements(p_project.deposit_id));
  
    insert into t9465a33
      (key,
       rfr,
       idx,
       vlu)
      select t9465a33$seq.nextval,
             p_project.main_project_version_id,
             rownum,
             column_value
        from table(wrapper_dim_elements(p_project.lu_id));
  
    pkg_rw_data_blocks.add_data_block(p_project_version_id => p_project.main_project_version_id,
                                      p_expertise_id       => null,
                                      p_name               => 'Параметры проекта',
                                      p_type_id            => pkg_rw_data_blocks.c_block_type_param_project,
                                      p_sub_type_id        => null,
                                      p_departament_id     => null,
                                      p_block              => l_block_param_project);
  
    pkg_rw_data_blocks.add_data_block(p_project_version_id => p_project.main_project_version_id,
                                      p_expertise_id       => null,
                                      p_name               => 'Этап проекта',
                                      p_type_id            => pkg_rw_data_blocks.c_block_type_step_project,
                                      p_sub_type_id        => null,
                                      p_departament_id     => null,
                                      p_block              => l_block_step_project);
  
    pkg_rw_data_blocks.add_data_block(p_project_version_id => p_project.main_project_version_id,
                                      p_expertise_id       => null,
                                      p_name               => pkg_rw_dict.rw_dict_name(p_dict_id => osp_dict_keys.c_id_dict_rw_kpi),
                                      p_type_id            => pkg_rw_data_blocks.c_block_type_kpi,
                                      p_sub_type_id        => null,
                                      p_departament_id     => null,
                                      p_block              => l_block_kpi);
  
    pkg_rw_data_blocks.add_data_block(p_project_version_id => p_project.main_project_version_id,
                                      p_expertise_id       => null,
                                      p_name               => 'Общая информация',
                                      p_type_id            => pkg_rw_data_blocks.c_block_type_info_project,
                                      p_sub_type_id        => null,
                                      p_departament_id     => null,
                                      p_block              => l_block_info_project);
  
    pkg_rw_data_blocks.add_data_block(p_project_version_id => p_project.main_project_version_id,
                                      p_expertise_id       => null,
                                      p_name               => 'Структура потенциалов проекта',
                                      p_type_id            => pkg_rw_data_blocks.c_block_type_graph,
                                      p_sub_type_id        => pkg_rw_data_blocks.c_graph_type_prj_potentials,
                                      p_departament_id     => null,
                                      p_block              => l_block_prj_potentials);
  
    pkg_notification.create_event(p_type   => pkg_notification.c_event_type_rw_create_project,
                                  p_params => t_param_events(t_param_event(p_param_id    => pkg_notification.c_param_rw_project_version_id,
                                                                           p_param_value => p_project.main_project_version_id)));
  end;

  --редактирование проекта
  procedure edit_project(p_project in out typ_project) as
    l_auto_project_code number;
    l_project_code      varchar2(10);
  begin
    p_project.check_project;
  
    select p.auto_code into l_auto_project_code from t9462 p where p.key = p_project.project_id;
  
    generate_project_code(p_project_type_id => p_project.type_project_id,
                          p_sort_project_id => p_project.sort_project,
                          p_init_year       => p_project.init_year,
                          p_code            => l_project_code);
  
    update t9462 p
       set p.project_code = case
                              when l_auto_project_code = 0
                                   and p_project.auto_project_code = 0 then
                               p_project.project_code
                              when l_auto_project_code = 0
                                   and p_project.auto_project_code = 1 then
                               l_project_code
                              when l_auto_project_code = 1
                                   and p_project.auto_project_code = 1 then
                               case
                                 when p.sort_project = p_project.sort_project
                                      and p.type_id = p_project.type_project_id
                                      and p.init_year = p_project.init_year then
                                  p.project_code
                                 else
                                  l_project_code
                               end
                              when l_auto_project_code = 1
                                   and p_project.auto_project_code = 0 then
                               p_project.project_code
                            end,
           p.sort_project         = p_project.sort_project,
           p.type_id              = p_project.type_project_id,
           p.auto_code            = p_project.auto_project_code,
           p.parent_key           = p_project.parent_project_id,
           p.init_year            = p_project.init_year,
           p.monitoring_status_id = p_project.monitoring_status_id
     where p.key = p_project.project_id;
  
    select p.project_code into p_project.project_code from t9462 p where p.key = p_project.project_id;
  
    update t9465 vp
       set name                  = p_project.name,
           direction_id          = p_project.direction_id,
           project_manager_id    = p_project.project_manager_id,
           curate_direction_id   = p_project.curate_direction_id,
           program_id            = p_project.program_id,
           bn_id                 = p_project.bn_id,
           be_spo_id             = p_project.be_spo_id,
           be_id                 = p_project.be_id,
           step_project_id       = p_project.step_id,
           approved_expertise_id = p_project.approved_expertise_id
     where vp.key = p_project.main_project_version_id;
  
    delete from t9465a11 where rfr = p_project.main_project_version_id;
    delete from t9465a12 where rfr = p_project.main_project_version_id;
    delete from t9465a33 where rfr = p_project.main_project_version_id;
  
    insert into t9465a11
      (key,
       rfr,
       idx,
       vlu)
      select t9465a11$seq.nextval,
             p_project.main_project_version_id,
             rownum,
             column_value
        from table(wrapper_dim_elements(p_project.active_id));
  
    insert into t9465a12
      (key,
       rfr,
       idx,
       vlu)
      select t9465a12$seq.nextval,
             p_project.main_project_version_id,
             rownum,
             column_value
        from table(wrapper_dim_elements(p_project.deposit_id));
  
    insert into t9465a33
      (key,
       rfr,
       idx,
       vlu)
      select t9465a33$seq.nextval,
             p_project.main_project_version_id,
             rownum,
             column_value
        from table(wrapper_dim_elements(p_project.lu_id));
  
  end;

  --чтение проекта
  procedure read_project(p_project_version_id in number, p_project out typ_project) as
  begin
    select typ_project(project_id              => p.key,
                       main_project_version_id => vp.key,
                       name                    => vp.name,
                       type_project_id         => p.type_id,
                       sort_project            => p.sort_project,
                       init_year               => p.init_year,
                       project_code            => p.project_code,
                       auto_project_code       => p.auto_code,
                       parent_project_id       => p.parent_key,
                       lu_id                   => cast(multiset (select vlu from t9465a33 where rfr = vp.key) as t_dim_elements),
                       active_id               => cast(multiset (select vlu from t9465a11 where rfr = vp.key) as t_dim_elements),
                       deposit_id              => cast(multiset (select vlu from t9465a12 where rfr = vp.key) as t_dim_elements),
                       project_manager_id      => vp.project_manager_id,
                       curate_direction_id     => vp.curate_direction_id,
                       direction_id            => vp.direction_id,
                       program_id              => vp.program_id,
                       bn_id                   => vp.bn_id,
                       be_spo_id               => vp.be_spo_id,
                       be_id                   => vp.be_id,
                       step_id                 => vp.step_project_id,
                       approved_expertise_id   => vp.approved_expertise_id,
                       monitoring_status_id    => p.monitoring_status_id)
      into p_project
      from t9462 p,
           t9465 vp
     where vp.project_id = p.key
       and vp.key = p_project_version_id;
  
  end;

  --Проверка перед удалением проекта (по ключу версии проекта)
  procedure chk_delete_projects(p_project_version_id in t_dim_elements, p_deletable_project_version_id out t_dim_elements, p_message_list out t_groups_message) as
    l_message_list t_messages_load;
  begin
  
    select column_value
      bulk collect
      into p_deletable_project_version_id
      from table(wrapper_dim_elements(p_project_version_id))
     where not exists (select 1
              from t9474a6 ll,
                   t9465   vp
             where vp.key = column_value
               and vp.project_id = ll.vlu);
  
    select t_message_load(text         => vp.name || ' (' || k.project_code || ')',
                          name_group   => case
                                            when d.column_value is null then
                                             'В системе созданы версии проекта(ов) для вынесения на коллегиальные органы. Удаление невозможно'
                                            else
                                             'Проекты будут удалены'
                                          end,
                          error_status => case
                                            when d.column_value is null then
                                             exception_pkg.c_error_message_type_error
                                            else
                                             exception_pkg.c_error_message_type_warning
                                          end)
      bulk collect
      into l_message_list
      from t9465 vp,
           t9462 k,
           table(wrapper_dim_elements(p_project_version_id)) e,
           table(wrapper_dim_elements(p_deletable_project_version_id)) d
     where vp.key = e.column_value
       and vp.key = d.column_value(+)
       and k.key = vp.project_id;
  
    p_message_list := message2group(p_message_list => l_message_list);
  end;

  --удаление проекта (по ключу версии проекта)
  procedure delete_project(p_project_version_id in number) as
    l_name varchar2(4000);
  begin
    select vp.name into l_name from t9465 vp where vp.key = p_project_version_id;
  
    update t9462 p set p.is_deleted = 1 where p.key in (select vp.project_id from t9465 vp where vp.key = p_project_version_id);
  
    pkg_notification.create_event(p_type   => pkg_notification.c_event_type_rw_project_delete,
                                  p_params => t_param_events(t_param_event(p_param_id    => pkg_notification.c_param_rw_project_version_id,
                                                                           p_param_value => p_project_version_id),
                                                             t_param_event(p_param_id => pkg_notification.c_param_comment, p_param_value => l_name)));
  
  end;

  --удаление проекта (по ключу версии проекта)
  procedure delete_projects(p_project_version_id in t_dim_elements) as
  begin
    for i in 1 .. p_project_version_id.count
    loop
      delete_project(p_project_version_id => p_project_version_id(i));
    end loop;
  end;

  --код проекта
  procedure generate_project_code(p_project_type_id in number, p_sort_project_id in number, p_init_year in date, p_code out varchar2) as
    l_idx number;
  begin
  
    select nvl(max(to_number(regexp_substr(p.project_code, '(\d+)', 1, 2))), 0) + 1
      into l_idx
      from t9462  p,
           t11283 t,
           t11283 t2
     where p.sort_project = p_sort_project_id
       and p.type_id = t.key
       and t.code = t2.code
       and t2.key = p_project_type_id
       and p.init_year = p_init_year;
  
    select t.code || to_char(p_init_year, 'yy') || 'P' || sp.code || lpad(l_idx, 4, 0)
      into p_code
      from t11283 t,
           t9468  sp
     where t.key = p_project_type_id
       and sp.key = p_sort_project_id;
  
  end;

  --проверка перед загрузкой из excel
  procedure chkload_project(p_data in typ_excl_projects, p_load_id out number, p_message_list out t_groups_message) as
    l_project          typ_project;
    l_full             number;
    l_message_list     t_messages_load;
    l_is_new           number;
    l_type_project_id  number;
    l_sort_project_id  number;
    l_init_year        date;
    l_tmp_list         tstringlist_table;
    l_tmp_message_list t_messages_load;
    l_scenario_id      number;
  begin
    p_load_id      := load_id_seq.nextval;
    l_message_list := t_messages_load();
    l_full         := pkg_user.check_web_permission(p_web_res_id        => pkg_web_component.c_web_id_rw_card_reestr,
                                                    p_acc_permission_id => pkg_user.c_permission_edit);
  
    l_scenario_id := pkg_forecast.actual_scenario;
  
    for i in 1 .. p_data.count
    loop
      begin
        l_project := typ_project();
      
        begin
          select p.key,
                 vp.key,
                 upper(trim(p.project_code)),
                 p.auto_code,
                 p.type_id,
                 p.sort_project,
                 p.init_year,
                 approved_expertise_id
            into l_project.project_id,
                 l_project.main_project_version_id,
                 l_project.project_code,
                 l_project.auto_project_code,
                 l_type_project_id,
                 l_sort_project_id,
                 l_init_year,
                 l_project.approved_expertise_id
            from t9462 p,
                 t9465 vp
           where vp.project_id = p.key
             and upper(trim(p.project_code)) = upper(trim(p_data(i).project_code));
        
          l_is_new := 0;
        exception
          when no_data_found then
            l_is_new := 1;
            if l_full = 1
            then
              l_project.project_code := upper(trim(p_data(i).project_code));
              if l_project.project_code is not null
              then
                l_project.auto_project_code := 0;
              else
                l_project.auto_project_code := 1;
              end if;
            else
              l_project.auto_project_code := 1;
            end if;
          when too_many_rows then
            l_message_list.extend(1);
            l_message_list(l_message_list.count) := t_message_load(text         => 'Cтрока ' || p_data(i).excl_row_id ||
                                                                                   ': Не удалось однозначно определить проект. Строка будет пропущена',
                                                                   name_group   => 'Ошибка',
                                                                   error_status => exception_pkg.c_error_message_type_error);
            continue;
        end;
      
        if l_full = 1
           or l_is_new = 1
        then
          begin
            select key into l_project.sort_project from t9468 where upper(trim(name)) = upper(trim(p_data(i).sort_project));
          exception
            when no_data_found then
              l_message_list.extend(1);
              l_message_list(l_message_list.count) := t_message_load(text         => 'Cтрока ' || p_data(i).excl_row_id ||
                                                                                     ': Вид проекта не распознан. Строка будет пропущена',
                                                                     name_group   => 'Ошибка',
                                                                     error_status => exception_pkg.c_error_message_type_error);
              continue;
          end;
        
          begin
            select key into l_project.type_project_id from t11283 where upper(trim(name)) = upper(trim(p_data(i).type_project));
          exception
            when no_data_found then
              l_message_list.extend(1);
              l_message_list(l_message_list.count) := t_message_load(text         => 'Cтрока ' || p_data(i).excl_row_id ||
                                                                                     ': Тип проекта не распознан. Строка будет пропущена',
                                                                     name_group   => 'Ошибка',
                                                                     error_status => exception_pkg.c_error_message_type_error);
              continue;
          end;
        
          l_project.init_year := nvl(p_data(i).init_year, trunc(sysdate, 'yyyy'));
        else
          l_project.sort_project    := l_sort_project_id;
          l_project.type_project_id := l_type_project_id;
          l_project.init_year       := l_init_year;
        end if;
      
        l_project.name := p_data(i).project_name;
      
        --родительский проект
        if p_data(i).parent_project is not null
        then
          begin
            select p.key
              into l_project.parent_project_id
              from t9462 p,
                   t9465 vp
             where upper(trim(p.project_code || ' ' || vp.name)) = upper(trim(p_data(i).parent_project))
               and vp.project_id = p.key;
          exception
            when no_data_found then
              l_message_list.extend(1);
              l_message_list(l_message_list.count) := t_message_load(text         => 'Cтрока ' || p_data(i).excl_row_id ||
                                                                                     ': Родительский проект не распознан. Значение будет пропущено',
                                                                     name_group   => 'Предупреждение',
                                                                     error_status => exception_pkg.c_error_message_type_warning);
            when too_many_rows then
              l_message_list.extend(1);
              l_message_list(l_message_list.count) := t_message_load(text         => 'Cтрока ' || p_data(i).excl_row_id ||
                                                                                     ': Родительский проект не определён однозначно. Значение будет пропущено',
                                                                     name_group   => 'Предупреждение',
                                                                     error_status => exception_pkg.c_error_message_type_warning);
          end;
        end if;
      
        --Лицензионный участок
        l_tmp_list := split_string(p_txt => p_data(i).lu, p_delimeter => ',');
      
        select t_message_load(text         => 'Cтрока ' || p_data(i).excl_row_id || ': Лицензионный участок ' || column_value ||
                                              ' не распознан. Значение будет пропущено',
                              name_group   => 'Предупреждение',
                              error_status => exception_pkg.c_error_message_type_warning)
          bulk collect
          into l_tmp_message_list
          from table(l_tmp_list)
         where not exists (select 1
                  from t_vers_lu l
                 where upper(trim(l.name)) = upper(trim(column_value))
                   and l.scenario_id = l_scenario_id);
      
        l_message_list := l_message_list multiset union l_tmp_message_list;
      
        select l.key
          bulk collect
          into l_project.lu_id
          from table(l_tmp_list),
               t_vers_lu l
         where upper(trim(l.name)) = upper(trim(column_value))
           and l.scenario_id = l_scenario_id;
      
        if l_project.lu_id.count = 0
        then
          l_message_list.extend(1);
          l_message_list(l_message_list.count) := t_message_load(text         => 'Cтрока ' || p_data(i).excl_row_id ||
                                                                                 ': Лицензионный участок обязателен для заполнения. Строка будет пропущена',
                                                                 name_group   => 'Ошибка',
                                                                 error_status => exception_pkg.c_error_message_type_error);
          continue;
        end if;
      
        --Месторождение
        l_tmp_list := split_string(p_txt => p_data(i).deposit, p_delimeter => ',');
      
        select t_message_load(text         => 'Cтрока ' || p_data(i).excl_row_id || ': Месторождение ' || column_value ||
                                              ' не распознано. Значение будет пропущено',
                              name_group   => 'Предупреждение',
                              error_status => exception_pkg.c_error_message_type_warning)
          bulk collect
          into l_tmp_message_list
          from table(l_tmp_list)
         where not exists (select 1
                  from t_vers_deposit d
                 where upper(trim(d.name)) = upper(trim(column_value))
                   and d.scenario_id = l_scenario_id);
      
        l_message_list := l_message_list multiset union l_tmp_message_list;
      
        select d.key
          bulk collect
          into l_project.deposit_id
          from table(l_tmp_list),
               t_vers_deposit d
         where upper(trim(d.name)) = upper(trim(column_value))
           and d.scenario_id = l_scenario_id;
      
        if l_project.deposit_id.count = 0
        then
          l_message_list.extend(1);
          l_message_list(l_message_list.count) := t_message_load(text         => 'Cтрока ' || p_data(i).excl_row_id ||
                                                                                 ': Месторождение обязательно для заполнения. Строка будет пропущена',
                                                                 name_group   => 'Ошибка',
                                                                 error_status => exception_pkg.c_error_message_type_error);
          continue;
        end if;
      
        --Актив
        l_tmp_list := split_string(p_txt => p_data(i).active, p_delimeter => ',');
      
        select t_message_load(text         => 'Cтрока ' || p_data(i).excl_row_id || ': Актив ' || column_value || ' не распознан. Значение будет пропущено',
                              name_group   => 'Предупреждение',
                              error_status => exception_pkg.c_error_message_type_warning)
          bulk collect
          into l_tmp_message_list
          from table(l_tmp_list)
         where not exists (select 1
                  from t_vers_active a
                 where upper(trim(a.name)) = upper(trim(column_value))
                   and a.scenario_id = l_scenario_id);
      
        l_message_list := l_message_list multiset union l_tmp_message_list;
      
        select a.key
          bulk collect
          into l_project.active_id
          from table(l_tmp_list),
               t_vers_active a
         where upper(trim(a.name)) = upper(trim(column_value))
           and a.scenario_id = l_scenario_id;
      
        if l_project.active_id.count = 0
        then
          l_message_list.extend(1);
          l_message_list(l_message_list.count) := t_message_load(text         => 'Cтрока ' || p_data(i).excl_row_id ||
                                                                                 ': Актив обязателен для заполнения. Строка будет пропущена',
                                                                 name_group   => 'Ошибка',
                                                                 error_status => exception_pkg.c_error_message_type_error);
          continue;
        end if;
      
        --Руководитель проекта
        if p_data(i).project_manager is not null
        then
          begin
            select u.key
              into l_project.project_manager_id
              from t2236 u
             where upper(trim(name)) = upper(trim(p_data(i).project_manager))
               and u.isdeleted = 0
               and nvl(u.is_system, 0) = 0;
          exception
            when no_data_found then
              l_message_list.extend(1);
              l_message_list(l_message_list.count) := t_message_load(text         => 'Cтрока ' || p_data(i).excl_row_id ||
                                                                                     ': Руководитель проекта не распознан. Значение будет пропущено',
                                                                     name_group   => 'Предупреждение',
                                                                     error_status => exception_pkg.c_error_message_type_warning);
          end;
        end if;
      
        --Статус мониторинга
        begin
          select key into l_project.monitoring_status_id from t11583 c where upper(trim(name)) = upper(trim(p_data(i).monitoring_status));
        exception
          when no_data_found then
            l_message_list.extend(1);
            l_message_list(l_message_list.count) := t_message_load(text         => 'Cтрока ' || p_data(i).excl_row_id ||
                                                                                   ': Статус мониторинга не распознан. Строка будет пропущена',
                                                                   name_group   => 'Ошибка',
                                                                   error_status => exception_pkg.c_error_message_type_error);
            continue;
        end;
      
        --Курирующая дирекция (ЕОЛ)
        begin
          select key into l_project.curate_direction_id from t10540 c where upper(trim(name)) = upper(trim(p_data(i).curate_direction));
        exception
          when no_data_found then
            l_message_list.extend(1);
            l_message_list(l_message_list.count) := t_message_load(text         => 'Cтрока ' || p_data(i).excl_row_id ||
                                                                                   ': ЕОЛ не распознан. Строка будет пропущена',
                                                                   name_group   => 'Ошибка',
                                                                   error_status => exception_pkg.c_error_message_type_error);
            continue;
        end;
      
        --Дирекция
        if p_data(i).direction is not null
        then
          begin
            select key into l_project.direction_id from t9540 c where upper(trim(name)) = upper(trim(p_data(i).direction));
          exception
            when no_data_found then
              l_message_list.extend(1);
              l_message_list(l_message_list.count) := t_message_load(text         => 'Cтрока ' || p_data(i).excl_row_id ||
                                                                                     ': Дирекция не распознана. Значение будет пропущено',
                                                                     name_group   => 'Предупреждение',
                                                                     error_status => exception_pkg.c_error_message_type_warning);
          end;
        end if;
      
        --Программа
        if p_data(i).program is not null
        then
          begin
            select key into l_project.program_id from t10843 c where upper(trim(name)) = upper(trim(p_data(i).program));
          exception
            when no_data_found then
              l_message_list.extend(1);
              l_message_list(l_message_list.count) := t_message_load(text         => 'Cтрока ' || p_data(i).excl_row_id ||
                                                                                     ': Программа не распознана. Значение будет пропущено',
                                                                     name_group   => 'Предупреждение',
                                                                     error_status => exception_pkg.c_error_message_type_warning);
          end;
        end if;
      
        --Статус мониторинга
        if p_data(i).monitoring_status is not null
        then
          begin
            select key into l_project.monitoring_status_id from t11583 c where upper(trim(name)) = upper(trim(p_data(i).monitoring_status));
          exception
            when no_data_found then
              l_message_list.extend(1);
              l_message_list(l_message_list.count) := t_message_load(text         => 'Cтрока ' || p_data(i).excl_row_id ||
                                                                                     ': Статус мониторинга не распознан. Значение будет пропущено',
                                                                     name_group   => 'Предупреждение',
                                                                     error_status => exception_pkg.c_error_message_type_warning);
          end;
        end if;
      
        --ОЕ
        begin
          select key,
                 bn_id,
                 be_id
            into l_project.be_spo_id,
                 l_project.bn_id,
                 l_project.be_id
            from t_vers_oe c
           where upper(trim(name)) = upper(trim(p_data(i).be_spo))
             and scenario_id = l_scenario_id;
        exception
          when no_data_found then
            l_message_list.extend(1);
            l_message_list(l_message_list.count) := t_message_load(text         => 'Cтрока ' || p_data(i).excl_row_id ||
                                                                                   ': ОЕ не распознана. Строка будет пропущена',
                                                                   name_group   => 'Ошибка',
                                                                   error_status => exception_pkg.c_error_message_type_error);
            continue;
        end;
      
        --этап проекта
        if p_data(i).step is not null
        then
          begin
            select key into l_project.step_id from t9471 c where upper(trim(name)) = upper(trim(p_data(i).step));
          exception
            when no_data_found then
              l_message_list.extend(1);
              l_message_list(l_message_list.count) := t_message_load(text         => 'Cтрока ' || p_data(i).excl_row_id ||
                                                                                     ': Этап не распознан. Значение будет пропущено',
                                                                     name_group   => 'Предупреждение',
                                                                     error_status => exception_pkg.c_error_message_type_warning);
          end;
        end if;
      
        begin
          l_project.check_project;
        exception
          when exception_pkg.ex_bad_status then
            l_message_list.extend(1);
            l_message_list(l_message_list.count) := t_message_load(text         => 'Cтрока ' || p_data(i).excl_row_id || ': ' || substr(sqlerrm, 12),
                                                                   name_group   => 'Ошибка',
                                                                   error_status => exception_pkg.c_error_message_type_error);
            continue;
        end;
      
        insert into t_excl_project
          (name,
           type_project_id,
           sort_project,
           init_year,
           project_code,
           auto_project_code,
           parent_project_id,
           lu_id,
           active_id,
           deposit_id,
           project_manager_id,
           curate_direction_id,
           direction_id,
           program_id,
           bn_id,
           be_spo_id,
           be_id,
           step_id,
           load_id,
           is_new,
           project_id,
           main_project_version_id,
           approved_expertise_id,
           monitoring_status_id)
          select l_project.name,
                 l_project.type_project_id,
                 l_project.sort_project,
                 l_project.init_year,
                 l_project.project_code,
                 l_project.auto_project_code,
                 l_project.parent_project_id,
                 l_project.lu_id,
                 l_project.active_id,
                 l_project.deposit_id,
                 l_project.project_manager_id,
                 l_project.curate_direction_id,
                 l_project.direction_id,
                 l_project.program_id,
                 l_project.bn_id,
                 l_project.be_spo_id,
                 l_project.be_id,
                 l_project.step_id,
                 p_load_id,
                 l_is_new,
                 l_project.project_id,
                 l_project.main_project_version_id,
                 l_project.approved_expertise_id,
                 l_project.monitoring_status_id
            from dual;
      
      exception
        when others then
          l_message_list.extend(1);
          l_message_list(l_message_list.count) := t_message_load(text         => 'Cтрока ' || p_data(i).excl_row_id || ': ' || sqlerrm,
                                                                 name_group   => 'Ошибка',
                                                                 error_status => exception_pkg.c_error_message_type_error);
          continue;
      end;
    end loop;
  
    p_message_list := message2group(p_message_list => l_message_list);
  
  end;

  --Загрузка проектов в Excel
  procedure load_project(p_load_id in number) as
    l_project typ_project;
  begin
    for z in (select * from t_excl_project where load_id = p_load_id)
    loop
      l_project := typ_project(project_id              => z.project_id,
                               main_project_version_id => z.main_project_version_id,
                               name                    => z.name,
                               type_project_id         => z.type_project_id,
                               sort_project            => z.sort_project,
                               init_year               => z.init_year,
                               project_code            => z.project_code,
                               auto_project_code       => z.auto_project_code,
                               parent_project_id       => z.parent_project_id,
                               lu_id                   => z.lu_id,
                               active_id               => z.active_id,
                               deposit_id              => z.deposit_id,
                               project_manager_id      => z.project_manager_id,
                               curate_direction_id     => z.curate_direction_id,
                               direction_id            => z.direction_id,
                               program_id              => z.program_id,
                               bn_id                   => z.bn_id,
                               be_spo_id               => z.be_spo_id,
                               be_id                   => z.be_id,
                               step_id                 => z.step_id,
                               approved_expertise_id   => z.approved_expertise_id,
                               monitoring_status_id    => z.monitoring_status_id);
      if z.is_new = 1
      then
        create_project(p_project => l_project);
      else
        edit_project(p_project => l_project);
      end if;
    end loop;
  end;

  --этапы
  procedure project_step_list(p_project_version_id in number, p_btns_list out t_button_list) as
    l_user_id number;
  begin
    l_user_id := pkg_user.getiduser;
  
    with user_group_role as
     (select ugr.group_role_id,
             ugr.role_id
        from t_user_group_role ugr
       where ugr.user_id = l_user_id),
    user_access as
     (select x.value,
             ugr.group_role_id
        from user_group_role ugr
        left join (select agr.group_role_id,
                         ua.value
                    from t_access_group_role agr,
                         t_user_access       ua
                   where agr.access_id = ua.id
                     and ua.dict_id = osp_dict_keys.c_id_dict_rw_project_step) x
          on ugr.group_role_id = x.group_role_id)
    select t_button(key    => key,
                    name   => name,
                    answer => case
                                when not exists (select 1 from user_access aa where nvl(aa.value, key) = key) then
                                 -1
                                when exists (select 1
                                        from t9465 vp
                                       where vp.key = p_project_version_id
                                         and vp.step_project_id = s.key) then
                                 1
                                else
                                 0
                              end)
      bulk collect
      into p_btns_list
      from t9471 s;
  end;

  --установить этап
  procedure set_project_step(p_project_version_id in number, p_step_id in number) as
    l_data_block_id number;
  begin
    update t9465 vp set vp.step_project_id = p_step_id where vp.key = p_project_version_id;
  
    select d.key
      into l_data_block_id
      from t9478 d
     where d.project_version_id = p_project_version_id
       and d.type_id = pkg_rw_data_blocks.c_block_type_param_project
       and rownum = 1;
  
    pkg_notification.create_event(p_type   => pkg_notification.c_event_type_rw_save_datablock,
                                  p_params => t_param_events(t_param_event(p_param_id    => pkg_notification.c_param_rw_project_version_id,
                                                                           p_param_value => p_project_version_id),
                                                             t_param_event(p_param_id    => pkg_notification.c_param_rw_data_block_id,
                                                                           p_param_value => l_data_block_id)));
  end;

  --построение шапки реестра
  function reestr_head return t_tabular_heads as
    l_head t_tabular_heads;
  begin
    select t_tabular_head(id                         => id,
                          name                       => name,
                          ord                        => ord,
                          parent_id                  => null,
                          editable                   => null,
                          deletable                  => null,
                          binding_editor             => null,
                          binding_editor_params      => null,
                          data_type                  => data_type,
                          custom_formats             => null,
                          pinned                     => null,
                          visible                    => visible,
                          header_component_framework => null,
                          header_component_params    => null,
                          header_class               => null,
                          head_id                    => head_id)
      bulk collect
      into l_head
      from (select c_head_id_name as id,
                   'Наименование' as name,
                   1 as ord,
                   1 as visible,
                   osp_rds.data_type_string as data_type,
                   'project_name' as head_id
              from dual
            union all
            select c_head_id_type_project as id,
                   'Тип' as name,
                   2 as ord,
                   1 as visible,
                   osp_rds.data_type_string as data_type,
                   'type_project' as head_id
              from dual
            union all
            select c_head_id_sort_project as id,
                   pkg_rw_dict.rw_dict_name(p_dict_id => osp_dict_keys.c_id_dict_rw_sort_project) as name,
                   3 as ord,
                   1 as visible,
                   osp_rds.data_type_string as data_type,
                   'sort_project' as head_id
              from dual
            union all
            select c_head_id_init_year as id,
                   'Год инициации проекта' as name,
                   4 as ord,
                   1 as visible,
                   osp_rds.data_type_int as data_type,
                   'init_year' as head_id
              from dual
            union all
            select c_head_id_project_code as id,
                   'Код проекта' as name,
                   5 as ord,
                   1 as visible,
                   osp_rds.data_type_string as data_type,
                   'project_code' as head_id
              from dual
            union all
            select c_head_id_monitoring as id,
                   'Статус мониторинга' as name,
                   6 as ord,
                   1 as visible,
                   osp_rds.data_type_string as data_type,
                   'monitoring_status' as head_id
              from dual
            union all
            select c_head_id_parent_project as id,
                   'Родительский проект' as name,
                   7 as ord,
                   1 as visible,
                   osp_rds.data_type_string as data_type,
                   'parent_project' as head_id
              from dual
            union all
            select c_head_id_lu as id,
                   'Лиценз. участок' as name,
                   8 as ord,
                   1 as visible,
                   osp_rds.data_type_string as data_type,
                   'lu' as head_id
              from dual
            union all
            select c_head_id_active as id,
                   'Актив' as name,
                   9 as ord,
                   1 as visible,
                   osp_rds.data_type_string as data_type,
                   'active' as head_id
              from dual
            union all
            select c_head_id_deposit as id,
                   'Месторождение' as name,
                   10 as ord,
                   1 as visible,
                   osp_rds.data_type_string as data_type,
                   'deposit' as head_id
              from dual
            union all
            select c_head_id_project_manager as id,
                   'Руководитель проекта' as name,
                   11 as ord,
                   1 as visible,
                   osp_rds.data_type_string as data_type,
                   'project_manager' as head_id
              from dual
            union all
            select c_head_id_curate_direction as id,
                   pkg_dict.dict_name(p_dict_id => osp_dict_keys.c_id_dict_rw_curate_direction) as name,
                   12 as ord,
                   1 as visible,
                   osp_rds.data_type_string as data_type,
                   'curate_direction' as head_id
              from dual
            union all
            select c_head_id_direction as id,
                   pkg_dict.dict_name(p_dict_id => osp_dict_keys.c_id_dict_rw_direction) as name,
                   13 as ord,
                   1 as visible,
                   osp_rds.data_type_string as data_type,
                   'direction' as head_id
              from dual
            union all
            select c_head_id_program as id,
                   pkg_rw_dict.rw_dict_name(p_dict_id => osp_dict_keys.c_id_dict_rw_program) as name,
                   14 as ord,
                   1 as visible,
                   osp_rds.data_type_string as data_type,
                   'program' as head_id
              from dual
            union all
            select c_head_id_bn as id,
                   'Бизнес-направление (БН)' as name,
                   15 as ord,
                   1 as visible,
                   osp_rds.data_type_string as data_type,
                   'bn' as head_id
              from dual
            union all
            select c_head_id_be as id,
                   'Бизнес-единица (БЕ)' as name,
                   16 as ord,
                   1 as visible,
                   osp_rds.data_type_string as data_type,
                   'be' as head_id
              from dual
            union all
            select c_head_id_be_spo as id,
                   'Операционная единица (ОЕ)' as name,
                   17 as ord,
                   1 as visible,
                   osp_rds.data_type_string as data_type,
                   'be_spo' as head_id
              from dual
            union all
            select c_head_id_step as id,
                   'Этап' as name,
                   18 as ord,
                   1 as visible,
                   osp_rds.data_type_string as data_type,
                   'step' as head_id
              from dual
            union all
            select c_head_id_open as id,
                   '' as name,
                   19 as ord,
                   0 as visible,
                   osp_rds.data_type_boolean as data_type,
                   'open' as head_id
              from dual
              union all
            select c_head_id_date as id,
                   'Дата добавления проета' as name,
                   20 as ord,
                   1 as visible,
                   osp_rds.data_type_date as data_type,
                   'date' as head_id
              from dual
              union all
            select c_head_id_who as id,
                   'Кто добавил' as name,
                   21 as ord,
                   1 as visible,
                   osp_rds.data_type_string as data_type,
                   'who' as head_id
              from dual);
  
    return l_head;
  end;

  --построение шапки реестра
  procedure reestr_head(p_head out t_tabular_heads) as
  begin
    p_head := reestr_head;
  end;

  --реестр проектов
  procedure init_project_reestr(p_client_id in number, p t_report_parameter) as
    l_head           t_tabular_heads;
    l_reestr_columns t_dim_elements;
  begin
  
    l_reestr_columns := p.get_dim_elements(osp_dict_keys.c_id_dict_rw_reestr_columns);
  
    l_head := reestr_head;
  
    insert into osp_tmp_tabular_head
      (client_id,
       id,
       name,
       ord,
       editable,
       visible,
       data_type,
       head_id)
      select p_client_id,
             id,
             name,
             ord,
             0 as editable,
             visible,
             data_type,
             head_id
        from table(l_head)
       where l_reestr_columns is null
          or exists (select 1 from table(wrapper_dim_elements(l_reestr_columns)) where column_value = id)
          or id = c_head_id_open;
  
    insert into osp_tmp_tabular_format_export
      (client_id,
       head_id,
       src_field)
    values
      (p_client_id,
       c_head_id_init_year,
       1);
  
    insert into osp_tmp_tabular_side
      (client_id,
       id,
       ord)
      select p_client_id,
             vp.project_version_id,
             -vp.project_version_id
        from v_rw_project_version vp
       where vp.role_id is not empty;
  
  end;

  --реестр проектов
  procedure init_project_reestr_data(p_client_id in number, p_data out sys_refcursor) as
    l_scenario_id number;
  begin
    l_scenario_id := pkg_forecast.actual_scenario;
  
    open p_data for
      select side_id,
             head_id,
             to_char(value) as value,
             value_text,
             0 as editable,
             null as custom_formats,
             null as binding_editor,
             null as binding_editor_params,
             null as data_type
        from (select h.id as head_id,
                     c.side_id,
                     case h.id
                       when c_head_id_name then
                        c.project_id
                       when c_head_id_open then
                        mb_open
                     end as value,
                     case h.id
                       when c_head_id_name then
                        c.name
                       when c_head_id_sort_project then
                        c.sort_project
                       when c_head_id_init_year then
                        c.init_year
                       when c_head_id_project_code then
                        c.project_code
                       when c_head_id_step then
                        c.step
                       when c_head_id_active then
                        c.active
                       when c_head_id_deposit then
                        c.deposit
                       when c_head_id_project_manager then
                        c.project_manager
                       when c_head_id_direction then
                        c.direction
                       when c_head_id_curate_direction then
                        c.curate_direction
                       when c_head_id_program then
                        c.program
                       when c_head_id_bn then
                        c.bn_id
                       when c_head_id_be then
                        c.be_id
                       when c_head_id_be_spo then
                        c.be_spo_id
                       when c_head_id_type_project then
                        c.type_project
                       when c_head_id_lu then
                        c.lu
                       when c_head_id_parent_project then
                        c.parent_project
                       when c_head_id_monitoring then
                        c.monitoring_status
                        when c_head_id_date then
                        c.cur_date
                        when c_head_id_who then
                        c.who
                     end as value_text
                from (select vp.project_version_id as side_id,
                             vp.project_version_id as ord,
                             vp.project_version_name as name,
                             (select sp.name from t9468 sp where sp.key = vp.sort_project) as sort_project,
                             to_char(vp.init_year, 'yyyy') as init_year,
                             vp.project_code,
                             (select s.name from t9471 s where s.key = vp.step_project_id) as step,
                             (select s.name from t2236 s where s.key = vp.project_manager_id) as project_manager,
                             (select s.name from t9540 s where s.key = vp.direction_id) as direction,
                             (select s.name from t10540 s where s.key = vp.curate_direction_id) as curate_direction,
                             (select s.name from t10843 s where s.key = vp.program_id) as program,
                             (select s.name from t11583 s where s.key = vp.monitoring_status_id) as monitoring_status,
                             (select s.name
                                from t_vers_bn s
                               where s.key = vp.bn_id
                                 and scenario_id = l_scenario_id) as bn_id,
                             (select s.name
                                from t_vers_oe s
                               where s.key = vp.be_spo_id
                                 and scenario_id = l_scenario_id) as be_spo_id,
                             (select s.name
                                from t_vers_be s
                               where s.key = vp.be_id
                                 and scenario_id = l_scenario_id) as be_id,
                             (select s.name from t11283 s where s.key = vp.project_type_id) as type_project,
                             (select k2.project_code || ' ' || vp2.name
                                from t9465 vp2,
                                     t9462 k2
                               where vp2.project_id = vp.parent_project_id
                                 and k2.key = vp.parent_project_id) as parent_project,
                             (select concatcomma(l.name)
                                from t_vers_lu l,
                                     t9465a33  a
                               where a.rfr = vp.project_version_id
                                 and a.vlu = l.key
                                 and l.scenario_id = l_scenario_id) as lu,
                             (select concatcomma(l.name)
                                from t_vers_active l,
                                     t9465a11      a
                               where a.rfr = vp.project_version_id
                                 and a.vlu = l.key
                                 and l.scenario_id = l_scenario_id) as active,
                             (select to_char(vp.create_date, 'dd.mm.yyyy') from t9468 sp where sp.key = vp.sort_project) as cur_date,
                             (select name from t2236 where key = (select vp.CREATE_USER_ID from t9468 sp where sp.key = vp.sort_project))  as who,
                             (select concatcomma(l.name)
                                from t_vers_deposit l,
                                     t9465a12       a
                               where a.rfr = vp.project_version_id
                                 and a.vlu = l.key
                                 and l.scenario_id = l_scenario_id) as deposit,
                             vp.project_id,
                             case
                               when exists (select 1
                                       from t_web_access a,
                                            table(wrapper_dim_elements(vp.role_id))
                                      where a.role_id = column_value
                                        and a.web_component_id = pkg_web_component.c_web_id_rw_project_version
                                        and a.access_read = 1) then
                                1
                               else
                                0
                             end as mb_open
                        from v_rw_project_version vp
                       where vp.role_id is not empty) c,
                     osp_tmp_tabular_head h
               where h.client_id = p_client_id);
  end;

  --роли пользователя в проекте
  function user_role(p_project_version_id in number) return t_dim_elements as
    l_roles_id            t_dim_elements;
    l_user_id             number;
    l_project_id          number;
    l_sort_project_id     number;
    l_step_project_id     number;
    l_curate_direction_id number;
  begin
    l_user_id := pkg_user.getiduser;
  
    select k.key as project_id,
           vp.step_project_id,
           k.sort_project,
           vp.curate_direction_id
      into l_project_id,
           l_step_project_id,
           l_sort_project_id,
           l_curate_direction_id
      from t9462 k,
           t9465 vp
     where vp.project_id = k.key
       and k.is_deleted = 0
       and vp.key = p_project_version_id;
  
    with user_group_role as
     (select ugr.group_role_id,
             ugr.role_id
        from t_user_group_role ugr
       where ugr.user_id = l_user_id),
    user_access as
     (select x.value,
             t.rfr as dict_id,
             ugr.group_role_id
        from user_group_role ugr
        join t9922a9 t
          on ugr.role_id = t.vlu
        left join (select agr.group_role_id,
                         ua.value,
                         ua.dict_id
                    from t_access_group_role agr,
                         t_user_access       ua
                   where agr.access_id = ua.id) x
          on ugr.group_role_id = x.group_role_id
         and rfr = x.dict_id)
    select r.role_id
      bulk collect
      into l_roles_id
      from user_group_role r
     where exists (select 1
              from user_access aa
             where aa.dict_id = osp_dict_keys.c_id_dict_rw_sort_project
               and nvl(aa.value, l_sort_project_id) = l_sort_project_id
               and aa.group_role_id = r.group_role_id)
       and exists (select 1
              from user_access aa
             where aa.dict_id = osp_dict_keys.c_id_dict_rw_project_step
               and coalesce(aa.value, l_step_project_id, -1) = nvl(l_step_project_id, -1)
               and aa.group_role_id = r.group_role_id)
       and exists (select 1
              from user_access aa
             where aa.dict_id = osp_dict_keys.c_id_dict_rw_project
               and nvl(aa.value, l_project_id) = l_project_id
               and aa.group_role_id = r.group_role_id)
       and exists (select 1
              from user_access aa
             where aa.dict_id = osp_dict_keys.c_id_dict_rw_curate_direction
               and coalesce(aa.value, l_curate_direction_id, -1) = nvl(l_curate_direction_id, -1)
               and aa.group_role_id = r.group_role_id);
  
    return set(l_roles_id);
  end;

  --роли (группы прав) пользователя в проекте
  function user_group_role(p_project_version_id in number) return t_dim_elements as
    l_group_role_id       t_dim_elements;
    l_user_id             number;
    l_project_id          number;
    l_sort_project_id     number;
    l_step_project_id     number;
    l_curate_direction_id number;
  begin
    l_user_id := pkg_user.getiduser;
  
    select k.key as project_id,
           vp.step_project_id,
           k.sort_project,
           vp.curate_direction_id
      into l_project_id,
           l_step_project_id,
           l_sort_project_id,
           l_curate_direction_id
      from t9462 k,
           t9465 vp
     where vp.project_id = k.key
       and k.is_deleted = 0
       and vp.key = p_project_version_id;
  
    with user_group_role as
     (select ugr.group_role_id,
             ugr.role_id
        from t_user_group_role ugr
       where ugr.user_id = l_user_id),
    user_access as
     (select x.value,
             t.rfr as dict_id,
             ugr.group_role_id
        from user_group_role ugr
        join t9922a9 t
          on ugr.role_id = t.vlu
        left join (select agr.group_role_id,
                         ua.value,
                         ua.dict_id
                    from t_access_group_role agr,
                         t_user_access       ua
                   where agr.access_id = ua.id) x
          on ugr.group_role_id = x.group_role_id
         and rfr = x.dict_id)
    select r.group_role_id
      bulk collect
      into l_group_role_id
      from user_group_role r
     where exists (select 1
              from user_access aa
             where aa.dict_id = osp_dict_keys.c_id_dict_rw_sort_project
               and nvl(aa.value, l_sort_project_id) = l_sort_project_id
               and aa.group_role_id = r.group_role_id)
       and exists (select 1
              from user_access aa
             where aa.dict_id = osp_dict_keys.c_id_dict_rw_project_step
               and coalesce(aa.value, l_step_project_id, -1) = nvl(l_step_project_id, -1)
               and aa.group_role_id = r.group_role_id)
       and exists (select 1
              from user_access aa
             where aa.dict_id = osp_dict_keys.c_id_dict_rw_project
               and nvl(aa.value, l_project_id) = l_project_id
               and aa.group_role_id = r.group_role_id)
       and exists (select 1
              from user_access aa
             where aa.dict_id = osp_dict_keys.c_id_dict_rw_curate_direction
               and coalesce(aa.value, l_curate_direction_id, -1) = nvl(l_curate_direction_id, -1)
               and aa.group_role_id = r.group_role_id);
  
    return l_group_role_id;
  end;

  --получение списка прав доступа на web-компоненты внутри проекта для текущего пользователя
  procedure permission_list_on_project(p_project_version_id in number, p_permission out sys_refcursor) as
    l_user_id             number;
    l_decisions           number;
    l_project_id          number;
    l_sort_project_id     number;
    l_step_project_id     number;
    l_curate_direction_id number;
    l_bn_id               number;
    l_be_id               number;
    l_be_spo_id           number;
  begin
    l_user_id := pkg_user.getiduser;
  
    select count(1)
      into l_decisions
      from dual
     where exists (select 1
              from t9474a6 a,
                   t9465   vp
             where a.vlu = vp.project_id
               and vp.key = p_project_version_id);
  
    select k.key as project_id,
           vp.step_project_id,
           k.sort_project,
           vp.curate_direction_id,
           vp.bn_id,
           vp.be_spo_id,
           vp.be_id
      into l_project_id,
           l_step_project_id,
           l_sort_project_id,
           l_curate_direction_id,
           l_bn_id,
           l_be_spo_id,
           l_be_id
      from t9462 k,
           t9465 vp
     where vp.project_id = k.key
       and k.is_deleted = 0
       and vp.key = p_project_version_id;
  
    open p_permission for
      with user_group_role as
       (select ugr.group_role_id,
               ugr.role_id
          from t_user_group_role ugr
         where ugr.user_id = l_user_id),
      user_access as
       (select x.value,
               t.rfr as dict_id,
               ugr.group_role_id
          from user_group_role ugr
          join t9922a9 t
            on ugr.role_id = t.vlu
          left join (select agr.group_role_id,
                           ua.value,
                           ua.dict_id
                      from t_access_group_role agr,
                           t_user_access       ua
                     where agr.access_id = ua.id) x
            on ugr.group_role_id = x.group_role_id
           and rfr = x.dict_id)
      select w.resource_id,
             w.key as web_component_id,
             max(a.access_read) as access_read,
             max(a.access_read_write) as access_read_write,
             max(a.access_delete) as access_delete,
             max(a.access_not_read) as access_not_read,
             max(a.access_not_read_write) as access_not_read_write,
             max(a.access_not_delete) as access_not_delete
        from t_web_access a,
             (select key,
                     resource_id
                from t2069
              connect by prior key = parent_key
               start with parent_key = pkg_web_component.c_web_id_rw_project_reestr) w,
             user_group_role ugr
       where w.key = a.web_component_id
         and ugr.role_id = a.role_id
         and exists (select 1
                from user_access aa
               where aa.dict_id = osp_dict_keys.c_id_dict_rw_sort_project
                 and nvl(aa.value, l_sort_project_id) = l_sort_project_id
                 and aa.group_role_id = ugr.group_role_id)
         and exists (select 1
                from user_access aa
               where aa.dict_id = osp_dict_keys.c_id_dict_rw_project_step
                 and coalesce(aa.value, l_step_project_id, -1) = nvl(l_step_project_id, -1)
                 and aa.group_role_id = ugr.group_role_id)
         and exists (select 1
                from user_access aa
               where aa.dict_id = osp_dict_keys.c_id_dict_rw_project
                 and nvl(aa.value, l_project_id) = l_project_id
                 and aa.group_role_id = ugr.group_role_id)
         and exists (select 1
                from user_access aa
               where aa.dict_id = osp_dict_keys.c_id_dict_rw_curate_direction
                 and coalesce(aa.value, l_curate_direction_id, -1) = nvl(l_curate_direction_id, -1)
                 and aa.group_role_id = ugr.group_role_id)
         and exists (select 1
                from user_access aa
               where aa.dict_id = osp_dict_keys.c_id_dict_rw_bn
                 and coalesce(aa.value, l_bn_id, -1) = nvl(l_bn_id, -1)
                 and aa.group_role_id = ugr.group_role_id)
         and exists (select 1
                from user_access aa
               where aa.dict_id = osp_dict_keys.c_id_dict_be
                 and coalesce(aa.value, l_be_id, -1) = nvl(l_be_id, -1)
                 and aa.group_role_id = ugr.group_role_id)
         and exists (select 1
                from user_access aa
               where aa.dict_id = osp_dict_keys.c_id_dict_mi_oe
                 and coalesce(aa.value, l_be_spo_id, -1) = nvl(l_be_spo_id, -1)
                 and aa.group_role_id = ugr.group_role_id)
       group by w.resource_id,
                w.key;
  end;

  --Регистрация события о просмотре проекта
  procedure set_event_in_project(p_project_version_id in number) as
  begin
    pkg_notification.create_event(p_type   => pkg_notification.c_event_type_rw_in_project,
                                  p_params => t_param_events(t_param_event(p_param_id    => pkg_notification.c_param_rw_project_version_id,
                                                                           p_param_value => p_project_version_id)));
  end;

  --Регистрация события о включении режима редактирования проекта
  procedure set_event_edit_project(p_project_version_id in number) as
  begin
    pkg_notification.create_event(p_type   => pkg_notification.c_event_type_rw_edit_project,
                                  p_params => t_param_events(t_param_event(p_param_id    => pkg_notification.c_param_rw_project_version_id,
                                                                           p_param_value => p_project_version_id)));
  end;

end pkg_rw_project;
