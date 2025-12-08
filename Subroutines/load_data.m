function data = load_data(fileExtension, equipment, loadFile)

switch fileExtension
    case 'AllFiles'
        switch equipment
            case 'AllFiles'
                data = load_AllFiles_AllFiles(loadFile);
        end
    case 'agd'
        switch equipment
            case 'Actigraph'
                data = load_agd_Actigraph(loadFile);
            case 'Axivity'
                data = load_csv_Axivity(loadFile);
        end
    case 'csv'
        switch equipment
            case 'BertecCDP'
                data = load_csv_BertecCDP(loadFile);
            case 'DAMVi'
                data = load_csv_DAMVi(loadFile);
            case 'Delsys'
                data = load_csv_Delsys(loadFile);
            case 'NHATSAcceleration'
                data = load_csv_NHATSAcceleration(loadFile);
            case 'Actigraph'
                data = load_csv_Actigraph(loadFile);
            case 'Basic'
                data = load_csv_Basic(loadFile);
            case 'Pfizer01'
                data = load_csv_Pfizer01(loadFile);
            case 'Pfizer02'
                data = load_csv_Pfizer02(loadFile);
        end
    case 'gt3x'
        switch equipment
            case 'Actigraph'
                data = load_gt3x_Actigraph(loadFile);
        end
    case 'h5'
        switch equipment
            case 'APDM0Met'
                data = load_h5_APDM0Met(loadFile);
            case 'APDM1Raw'
                data = load_h5_APDM1Raw(loadFile);
            case 'APDM1RawLumbar'
                data = load_h5_APDM1RawLumbar(loadFile);
            case 'APDM1RawRightFoot'
                data = load_h5_APDM1RawRightFoot(loadFile);
            case 'APDM1RawUpperLeg'
                data = load_h5_APDM1RawUpperLeg(loadFile);
            case 'APDM2Results'
                data = load_h5_APDM2Results(loadFile);
            case 'APDM3Qua'
                data = load_h5_APDM3Qua(loadFile);
            case 'APDM3QuaLumbar'
                data = load_h5_APDM3QuaLumbar(loadFile);
            case 'APDM3QuaRightFoot'
                data = load_h5_APDM3QuaRightFoot(loadFile);
        end
    case 'm'
        switch equipment
            case 'MATLAB'
                data = load_m_MATLAB(loadFile);
        end
    case 'mat'
        switch equipment
            case 'DAMVi'
                data = load_mat_DAMVi(loadFile);
            case 'OpenCap'
                data = load_mat_OpenCap(loadFile);
            case 'QTM'
                data = load_mat_QTM(loadFile);
            case 'QTMDelsysVL'
                data = load_mat_QTMDelsysVL(loadFile);
        end
    case 'mlapp'
        switch equipment
            case 'MATLAB'
                data = load_mlapp_MATLAB(loadFile);
        end
    case 'mot'
        switch equipment
            case 'OpenSim'
                data = load_mot_OpenSim(loadFile);
        end
    case 'png'
        switch equipment
            case 'WIN'
                data = load_png_WIN(loadFile);
        end
    case 'qtm'
        switch equipment
            case 'QTM'
                data = load_qtm_QTM(loadFile);
        end
    case 'txt'
        switch equipment
            case 'V3D'
                data = load_txt_V3D(loadFile);
        end
    case 'xlsx'
        switch equipment
            case 'Medoc'
                data = load_xlsx_Medoc(loadFile);
        end
end